From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Fri, 14 Apr 2017 18:38:53 -0600
Message-ID: <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
References: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55620 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755490AbdDOAiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:38:54 -0400
In-Reply-To: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-04-14 16:23, David Ahern wrote:
> Subash:
> 
> My understanding of early demux is that it should only match connected
> sockets (src/sport + dst/dport are all set). The ipv6 udp early demux
> code added in 5425077d73e0c is doing a generic socket lookup which does
> not require an exact match and accordingly breaks udp_l3mdev_accept=0.
> Please fix.
> 
> David

Hi David

Would it be possible to disable udp_early_demux for your case 
temporarily.
I'll look into this.
