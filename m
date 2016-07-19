From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 09:17:00 +0200
Message-ID: <1468912620.2178.5.camel@suse.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	 <1468846886.2280.6.camel@suse.com>
	 <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	 <1468849802.2280.11.camel@suse.com>
	 <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	 <1468851242.2280.14.camel@suse.com>
	 <CAKfDRXiK82ULw7RnRGdFwzad8NOfnwZN0vqv=08Tf+cNSdyd2g@mail.gmail.com>
	 <1468909209.2178.0.camel@suse.com>
	 <CAKfDRXjzgd58kS-MzUsZAsD66VCa5=qyqaLr_eZSm-XphxA7Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKfDRXjzgd58kS-MzUsZAsD66VCa5=qyqaLr_eZSm-XphxA7Mw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-19 at 08:40 +0200, Kristian Evensen wrote:
> On Tue, Jul 19, 2016 at 8:20 AM, Oliver Neukum <oneukum@suse.com> wrote:
> >> I had a look at some other drivers, and I think we need to be very
> >> careful about making setting a random MAC too generic. For example, we
> >> might be unlucky and break the possibly_iphdr()-code/assumption in
> >> qmi_wwan.c. And there is probably more code/assumptions like that in
> >> the network stack.
> >
> > In this case please use special cases for usbnet, too.
> > We need a quirk.
> 
> I guess I can match on the VID/PID in usbnet, but won't it be cleaner
> to add a new bind() function (in cdc_ether) which matches the two PIDs
> and leave usbnet as is? Or am I misunderstanding how to add this
> functionality to usbnet?

It would be cleaner, but it seems to me that multiple quirky devices
driven by diverse drivers use those bogus MACs. If you want to catch
them at a central place, it has to be usbnet. It is a matter of taste.
I am fine with either solution.

	Regards
		Oliver
