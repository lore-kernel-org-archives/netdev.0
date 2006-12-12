From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [RFC] rfkill - Add support for input key to control wireless radio
Date: Tue, 12 Dec 2006 08:47:07 +0100
Message-ID: <a32f33a40612112347hd359ca5q5962e12301d31bd6@mail.gmail.com>
References: <200612031936.34343.IvDoorn@gmail.com>
	 <d120d5000612061404x3f6e18e7qd3601c3b450a5f91@mail.gmail.com>
	 <200612072253.14492.IvDoorn@gmail.com>
	 <200612120012.28911.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>,
	"Lennart Poettering" <lennart@poettering.net>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750962AbWLLHrL@vger.kernel.org>
To: "Dmitry Torokhov" <dtor@insightbb.com>
In-Reply-To: <200612120012.28911.dtor@insightbb.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > > > > 2 - Hardware key that does not control the hardware radio and does not report anything to userspace
> > > > >
> > > > > Kind of uninteresting button ;)
> > > >
> > > > And this is the button that rfkill was originally designed for.
> > > > Laptops with integrated WiFi cards from Ralink have a hardware button that don't send anything to
> > > > userspace (unless the ACPI event is read) and does not directly control the radio itself.
> > > >
> > >
> > > So what does such a button do? I am confused here...
> >
> > Without a handler like rfkill, it does nothing besides toggling a bit in a register.
> > The Ralink chipsets have a couple of registers that represent the state of that key.
> > Besides that, there are no notifications to the userspace nor does it directly control the
> > radio.
> > That is where rfkill came in with the toggle handler that will listen to the register
> > to check if the key has been pressed and properly process the key event.
>
> In this case the driver can make the button state available to userspace so
> thsi is really type 2) driver as far as I can see. The fact that the button
> is not reported to userspace yet should not get into our way of classifying
> it.

I was indeed considering it as a type 2) device.
I am currently working on revising the rfkill driver to work as you suggested,
so I hope to have a new patch ready for you soon.

Ivo
