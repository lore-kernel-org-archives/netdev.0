From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH 1/7] MIPS: Octeon: Fix EIO handling.
Date: Thu, 07 Jan 2010 23:37:02 +0300
Message-ID: <4B4645EE.5050302@ru.mvista.com>
References: <4B463005.8060505@caviumnetworks.com> <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([206.112.117.35]:62122 "HELO
	imap.sh.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1753116Ab0AGUhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 15:37:34 -0500
In-Reply-To: <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

David Daney wrote:

> If an interrupt handler disables interrupts, the EOI function will
> just reenable them.  This will put us in an endless loop when the
> upcoming Ethernet driver patches are applied.
>
> Only reenable the interrupt on EOI if it is not IRQ_DISABLED.  This
> requires that the EIO function be separate from the ENABLE function.
> We also rename the ACK functions to correspond with their function.
>
> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
>   

   I guess the subject should read "EIO", not "EIO"...

WBR, Sergei


