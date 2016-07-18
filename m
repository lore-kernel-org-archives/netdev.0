From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 18 Jul 2016 16:27:36 +0200
Message-ID: <CAKfDRXhZvW493o-=jJGDhM5Woy7mLQMLas-2d7jwJLdV8dBFCQ@mail.gmail.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
 <1468846886.2280.6.camel@suse.com> <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
 <1468849802.2280.11.camel@suse.com> <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
 <1468851242.2280.14.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468851242.2280.14.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 4:14 PM, Oliver Neukum <oneukum@suse.com> wrote:
>> Ok, sounds good. So far, I have only seen the random MAC issue with
>> the three previously mentioned devices, but who knows how many else is
>> out there with the same error ... I don't think it should be in the
>> core ethernet code, at least not yet, but I agree it would make sense
>> to move it to for example usbnet_core(). If you agree, I can prepare a
>> patch for it.
>
> I don't see how it would be specific for a subsystem. If the patch
> is correct, it belongs into the networking core.

To me it sounds a bit intrusive to change the networking core for
something that has so far only been seen with devices belonging to one
subsystem, but I will do it if required. I guess David M. will have an
opinion on if we should add this fix on a per-driver basis, in usbnet
or in the networking core? If we go for the latter, what would be
correct place for this piece of code, register_netdevice()?

-Kristian
