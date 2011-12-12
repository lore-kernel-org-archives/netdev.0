From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Mon, 12 Dec 2011 16:44:01 +0100
Message-ID: <4EE62141.8010305@grandegger.com>
References: <4EE61928.10608@grandegger.com> <4EE61E3D.2090303@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE61E3D.2090303@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/12/2011 04:31 PM, Marc Kleine-Budde wrote:
> On 12/12/2011 04:09 PM, Wolfgang Grandegger wrote:
>> As pointed out by Reuben Dowle and Lothar Wa=DFmann, the TWRN_INT,
>> RWRN_INT, BOFF_INT interrupt sources need to be cleared as well
>> to avoid interrupt flooding, at least for the Flexcan on i.MX28
>> SOCs. Furthermore, the interrupts are only cleared, if really one
>> of those interrupt sources are pending (which is not the case for
>> rx and tx done).
>>
>> CC: Reuben Dowle <Reuben.Dowle@navico.com>
>> CC: Lothar Wa=DFmann <LW@KARO-electronics.de>
>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>=20
> Have you tested on mx25/mx35, does it have any negative side effects?
> My schedule is full until Friday, sorry cannot test here.

Not yet. But it's not critical. Only the pending interrupt flags are
cleared. Maybe somebody else out there could do some testing... before =
I
get hold of a MX35PDK board.

Wolfgang.
