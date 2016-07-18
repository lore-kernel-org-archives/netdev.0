From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 18 Jul 2016 16:10:31 +0200
Message-ID: <CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
 <1468846886.2280.6.camel@suse.com> <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
 <1468849802.2280.11.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468849802.2280.11.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 3:50 PM, Oliver Neukum <oneukum@suse.com> wrote:
> No, you misunderstand me. I don't want quirks if we can avoid it.
> But if you need to do this for rndis_host and cdc_ether and maybe other
> drivers you should not be touching drivers. This belongs into the core
> ethernet code. Your code is good, but you are putting it in the wrong
> places.

Ok, sounds good. So far, I have only seen the random MAC issue with
the three previously mentioned devices, but who knows how many else is
out there with the same error ... I don't think it should be in the
core ethernet code, at least not yet, but I agree it would make sense
to move it to for example usbnet_core(). If you agree, I can prepare a
patch for it.
