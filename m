From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH V2 1/4] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 17:05:11 +0530
Message-ID: <545A0B6F.8060706@gmail.com>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, wg@grandegger.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58443 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbaKELiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 06:38:19 -0500
In-Reply-To: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dong Aisheng,

On 11/05/2014 01:28 PM, Dong Aisheng wrote:

> Bosch M_CAN is CAN FD capable device. This patch implements the CAN
> FD features include up to 64 bytes payload and bitrate switch function.
> 1) Change the Rx FIFO and Tx Buffer to 64 bytes for support CAN FD
>     up to 64 bytes payload. It's backward compatible with old 8 bytes
>     normal CAN frame.
> 2) Allocate can frame or canfd frame based on EDL bit
> 3) Bitrate Switch function is disabled by default and will be enabled
>     according to CANFD_BRS bit in cf->flags.
>
> Signed-off-by: Dong Aisheng <b29396@freescale.com>

In these four patches two of them are V1 and other two are V2.

Is there any reason..?

How will you be able to generate like this by git format-patch..?

-- 
Thanks and Regards,
Varka Bhadram.
