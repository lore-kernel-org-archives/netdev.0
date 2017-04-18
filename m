From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: ipv6: Fix UDP early demux lookup with
 udp_l3mdev_accept=0
Date: Tue, 18 Apr 2017 09:46:18 -0600
Message-ID: <d2f5b51a-9cf2-d35b-2f3c-1b22f3d8b31a@cumulusnetworks.com>
References: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
 <8729016553E3654398EA69218DA29EEF15B8090F@cnshjmbx02>
 <2a12c7c44ddd3e372a84db9318a40c98@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com,
        eric.dumazet@gmail.com, Eric Dumazet <edumazet@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33889 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdDRPqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:46:19 -0400
Received: by mail-pf0-f181.google.com with SMTP id c198so82847048pfc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:46:19 -0700 (PDT)
In-Reply-To: <2a12c7c44ddd3e372a84db9318a40c98@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/17 7:07 PM, Subash Abhinov Kasiviswanathan wrote:
>>> +        break;
>> I think break here should remove ?
> 
> Hi Yuan
> 
> This is similar to __udp4_lib_demux_lookup where we need to check if the
> first
> socket is an exact match or break since chains maybe long.
> 

I suggest adding the same comment as __udp4_lib_demux_lookup; it does
look odd.
