From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH 0/2] DMA API usage fixes in gianfar
Date: Fri, 5 Dec 2014 16:48:39 +0200
Message-ID: <5481C5C7.9080503@freescale.com>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<haokexin@gmail.com>
To: Arseny Solokha <asolokha@kb.kras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0104.outbound.protection.outlook.com ([65.55.169.104]:8736
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751135AbaLEPEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 10:04:32 -0500
In-Reply-To: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/2014 12:37 PM, Arseny Solokha wrote:
> Hello.
>
> This patch set fixes DMA API usage issues in gianfar ethernet driver
> reported by the kernel w/ DMA API debug enabled.
>
> There were even reports that the kernel sometimes oopsed in the past
> because of kernel paging request handling failures, though it was likely
> observed on some ancient versions. And while I personally doesn't have
> any strong evidence of this, there's no reason to let these possible
> failures live any longer.
>
> Arseny Solokha (2):
>    gianfar: handle map error in gfar_new_rxbdp()
>    gianfar: handle map error in gfar_start_xmit()
>
>   drivers/net/ethernet/freescale/gianfar.c | 49 ++++++++++++++++++++++++++------
>   1 file changed, 41 insertions(+), 8 deletions(-)
>

Thanks but please note that Kevin Hao already provided a fix for this issue:
http://permalink.gmane.org/gmane.linux.network/336274

His patch was only deferred for testing (and bandwidth) reasons.
I will try to resend his patch to the netdev list today if possible,
I apologize for the delay.
Also note that there are some issues with your patches.
As said before, I will resubmit Kevin Hao's patch.

Thanks,
Claudiu
