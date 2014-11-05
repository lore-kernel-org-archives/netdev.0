From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V3 2/3] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 15:42:00 +0100
Message-ID: <545A3738.2010007@hartkopp.net>
References: <1415193393-30023-1-git-send-email-b29396@freescale.com> <1415193393-30023-2-git-send-email-b29396@freescale.com> <545A34B9.2060001@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <545A34B9.2060001@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks good to me now.

Thanks for your patience.

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

On 05.11.2014 15:31, Marc Kleine-Budde wrote:
> On 11/05/2014 02:16 PM, Dong Aisheng wrote:
>> Bosch M_CAN is CAN FD capable device. This patch implements the CAN
>> FD features include up to 64 bytes payload and bitrate switch function.
>> 1) Change the Rx FIFO and Tx Buffer to 64 bytes for support CAN FD
>>     up to 64 bytes payload. It's backward compatible with old 8 bytes
>>     normal CAN frame.
>> 2) Allocate can frame or canfd frame based on EDL bit
>> 3) Bitrate Switch function is disabled by default and will be enabled
>>     according to CANFD_BRS bit in cf->flags.
>>
>> Signed-off-by: Dong Aisheng <b29396@freescale.com>
>
> I'm waiting on Oliver's Ack on this patch, then I'll apply 1+2.
>
> regards,
> Marc
>
