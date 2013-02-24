From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net] bnx2x: remove dead code and make local funcs
 static
Date: Sun, 24 Feb 2013 22:25:20 +0200
Message-ID: <1361737520.3557.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20130222100110.057520e1@nehalam.linuxnetplumber.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dmitry@broadcom.com, yanivr@broadcom.com
To: "Stephen Hemminger" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1356 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757152Ab3BXUZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2013 15:25:37 -0500
In-Reply-To: <20130222100110.057520e1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-22 at 10:01 -0800, Stephen Hemminger wrote:
> Sparse warned about several functions that were unnecessarily global.
> After making them static, discovered that several functions were actually never used.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 

Hi Stephen,

Thanks for this patch. The "dead code" part is actually a missing call
in case of PHY FW upgrade for the 84833 PHY - without it, a server
reboot is required for the new PHY FW to take affect - but this reboot
saving enhancement should wait until net-next is open, so I'm acking
this patch and we will add the code back with the proper call once the
net-next is open again.

Acked-by: Eilon Greenstein <eilong@broadcomo.com>
