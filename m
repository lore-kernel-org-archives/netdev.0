From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v2] net: ipv6: Fix UDP early demux lookup with
 udp_l3mdev_accept=0
Date: Mon, 17 Apr 2017 19:07:55 -0600
Message-ID: <2a12c7c44ddd3e372a84db9318a40c98@codeaurora.org>
References: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
 <8729016553E3654398EA69218DA29EEF15B8090F@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, rshearma@brocade.com,
        eric.dumazet@gmail.com, Eric Dumazet <edumazet@google.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44182 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdDRBH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 21:07:57 -0400
In-Reply-To: <8729016553E3654398EA69218DA29EEF15B8090F@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +		break;
> I think break here should remove ?

Hi Yuan

This is similar to __udp4_lib_demux_lookup where we need to check if the 
first
socket is an exact match or break since chains maybe long.
