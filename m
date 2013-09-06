From: Stephane Grosjean <s.grosjean@peak-system.com>
Subject: Re: [PATCH] can: pcan_usb_core: fix memory leak on failure paths in
 peak_usb_start()
Date: Fri, 06 Sep 2013 08:58:29 +0200
Message-ID: <52297D15.9040108@peak-system.com>
References: <1378450379823688500@peak-system.com>
 <52297C8E.70101@pengutronix.de>
Reply-To: Stephane Grosjean <s.grosjean@peak-system.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52297C8E.70101@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 06/09/2013 08:56, Marc Kleine-Budde a =C3=A9crit :
> On 09/06/2013 08:52 AM, Stephane Grosjean wrote:
>> Tx and rx urbs are not deallocated if something goes wrong in peak_u=
sb_start().
>> The patch fixes error handling to deallocate all the resources.
>>
>> Found by Linux Driver Verification project (linuxtesting.org).
>>
>> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
>> Acked-by: Stephane Grosjean <s.grosjean@peak-system.com>
> Tnx,
> Marc
>
> BTW: A simply reply to the original patch with your Acked-by is suffi=
cient.
>

Ok, thx Marc. I keep it in mind for the next time (if any ;-))

St=C3=A9phane
--
PEAK-System Technik GmbH, Otto-Roehm-Strasse 69, D-64293 Darmstadt=20
Geschaeftsleitung: A.Gach/U.Wilhelm,St.Nr.:007/241/13586 FA Darmstadt=20
HRB-9183 Darmstadt, Ust.IdNr.:DE 202220078, WEE-Reg.-Nr.: DE39305391=20
Tel.+49 (0)6151-817320 / Fax:+49 (0)6151-817329, info@peak-system.com
