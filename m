From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH 2.6.25] add bnx2x driver for BCM57710 - bnx2x.c
Date: Fri, 16 Nov 2007 09:55:13 +0200
Message-ID: <473D4CE1.9070102@broadcom.com>
References: <1195154386.24548.29.camel@lb-tlvb-eliezer.il.broadcom.com>
 <1195155983.24548.35.camel@lb-tlvb-eliezer.il.broadcom.com>
 <20071115150349.51e6d133@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	"masbock" <masbock@us.ibm.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ram Pai" <linuxram@us.ibm.com>,
	"Philip Oswald" <poswald@novell.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2858 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103AbXKPH4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 02:56:35 -0500
In-Reply-To: <20071115150349.51e6d133@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

Thank you for taking the time to go over this.

Stephen Hemminger wrote:
> 1. Please use dev_err() to help user figure out which board has problem:
OK

> 2. Use new MAC_ADDR() rather than
OK

> 3. The reset task logic needs more cleanup/protection.
OK

> 4. Rather than hard coding mac address, could you use random_ether_address()
> instead?
I'm not sure,
This is only for some of the chip simulation environments that don't have an NVRAM.
Not for a real chip.

> 5. Current style police will complain about single line {}
OK (we all love the police. funny that checkpatch.pl did not find this)

> 6. The driver is using per-cpu tx queue, maybe it wants to have multi
> queue instead?
This is still not enabled by default.
We are limited to 16 queues and they are rather expansive, so I'm not sure what would be best.
Can you please give me pointers to examples?
In any case on the TX side you don't need more than one per cpu.

> 7. bnx2x_get_stats() is uneeded. If you leave dev->get_stats() set to NULL
> then register_netdev will handle it.
OK

> 8. Spelling fixes:
Thanks...

I will send the fixes as patches.
The reset change needs to be very carefully tested so this will only happen early next week.

Thanks,
Eliezer




