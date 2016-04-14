From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip: neigh: Fix leftover attributes message
 during flush
Date: Thu, 14 Apr 2016 17:04:46 -0600
Message-ID: <5710220E.6060303@cumulusnetworks.com>
References: <1460657703-8222-1-git-send-email-jefftharris@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Harris <jefftharris@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36310 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbcDNXEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 19:04:49 -0400
Received: by mail-io0-f169.google.com with SMTP id u185so119025733iod.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 16:04:49 -0700 (PDT)
In-Reply-To: <1460657703-8222-1-git-send-email-jefftharris@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/16 12:15 PM, Jeff Harris wrote:
> Use the same rtnl_dump_request_n call as the show.  The rtnl_wilddump_request
> assumes the type uses an ifinfomsg which is not the case for the neighbor
> table.
>
> Signed-off-by: Jeff Harris <jefftharris@gmail.com>
> ---

Acked-by: David Ahern <dsa@cumulusnetworks.com>

Fixes the "netlink: 12 bytes leftover after parsing attributes in 
process `ip'." message.
