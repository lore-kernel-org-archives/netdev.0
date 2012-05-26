From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] STA2X11 CAN: CAN driver for the STA2X11 board
Date: Sat, 26 May 2012 21:57:58 +0200
Message-ID: <4FC135C6.5030206@grandegger.com>
References: <1337288364-17572-1-git-send-email-federico.vaga@gmail.com> <4FB5E581.1090209@grandegger.com> <CAH5GJ0rFB4xaR7o-wVR3ze_UogeDW84dehh0rx5z+300ghB4uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giancarlo Asnaghi <giancarlo.asnaghi@st.com>,
	Alan Cox <alan@linux.intel.com>
To: Federico Vaga <federico.vaga@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAH5GJ0rFB4xaR7o-wVR3ze_UogeDW84dehh0rx5z+300ghB4uA@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2012 10:36 AM, Federico Vaga wrote:
>> Thanks for your contribution. At a first glance, this driver looks
>> similar to the pch_can and the c_can driver. It seems that a C_CAN based
>> controller is used on that board as well. If that's true, it should be
>> handled by the C_CAN driver. To get ride of the obsolete pch_can driver,
>> I sent some time ago the patch "[RFC/PATCH] c_can: add driver for the
>> PCH CAN controller":
>>
>>  http://marc.info/?t=132991563600003&r=1&w=4
>>
>> I could serve as base of a generic c_can_pci driver.
> 
> You are right, this is a C-CAN but it isn't specified on the board manual.
> I compared the board manual with the Bosch C-CAN manual, and it is the same.

Like with the Intel EG20T PCH CAN controller.

> I'm working on a PCI module for this board, when it is ready we can think for
> a generic c_can_pci

That would be nice, thanks. You might have realized that AnilKumar has
provided support for the D_CAN controllers to the C_CAN driver which
will show up mainline soon.

Wolfgang.

