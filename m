From: Federico Vaga <federico.vaga@gmail.com>
Subject: Re: [PATCH] STA2X11 CAN: CAN driver for the STA2X11 board
Date: Sat, 26 May 2012 10:36:10 +0200
Message-ID: <CAH5GJ0rFB4xaR7o-wVR3ze_UogeDW84dehh0rx5z+300ghB4uA@mail.gmail.com>
References: <1337288364-17572-1-git-send-email-federico.vaga@gmail.com> <4FB5E581.1090209@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FB5E581.1090209@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thanks for your contribution. At a first glance, this driver looks
> similar to the pch_can and the c_can driver. It seems that a C_CAN ba=
sed
> controller is used on that board as well. If that's true, it should b=
e
> handled by the C_CAN driver. To get ride of the obsolete pch_can driv=
er,
> I sent some time ago the patch "[RFC/PATCH] c_can: add driver for the
> PCH CAN controller":
>
> =C2=A0http://marc.info/?t=3D132991563600003&r=3D1&w=3D4
>
> I could serve as base of a generic c_can_pci driver.

You are right, this is a C-CAN but it isn't specified on the board manu=
al.
I compared the board manual with the Bosch C-CAN manual, and it is the =
same.
I'm working on a PCI module for this board, when it is ready we can thi=
nk for
a generic c_can_pci

Thank you

--=20
=46ederico Vaga
