From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/5] net: Add netif_is_l3_slave
Date: Mon, 5 Oct 2015 08:44:31 -0600
Message-ID: <56128CCF.3080209@cumulusnetworks.com>
References: <1443713247-11230-1-git-send-email-dsa@cumulusnetworks.com>
 <1443713247-11230-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34463 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbbJEOod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 10:44:33 -0400
Received: by padhy16 with SMTP id hy16so38845490pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 07:44:33 -0700 (PDT)
In-Reply-To: <1443713247-11230-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/1/15 9:27 AM, David Ahern wrote:
> IPv6 addrconf keys off of IFF_SLAVE so can not use it for L3 slave.
> Add a new private flag and add netif_is_l3_slave function for checking
> it.

After pulling in Cong's patch to address the warning on device remove I 
need to respin this one.
