From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 08 Aug 2016 20:30:35 +0200
Message-ID: <87oa535d10.fsf@miraculix.mork.no>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	<1468846886.2280.6.camel@suse.com>
	<CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	<1468849802.2280.11.camel@suse.com>
	<CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	<1468851242.2280.14.camel@suse.com> <87y4475t2f.fsf@miraculix.mork.no>
	<1470664620.3175.18.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470664620.3175.18.camel@suse.com> (Oliver Neukum's message of
	"Mon, 08 Aug 2016 15:57:00 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum@suse.com> writes:

> But why fix similar issues at two different places? And what about
> PCI or other cards that show the same problem?

I guess some sort of common helper would be nice to avoid open coding
this fix everywhere.  But you would still have to modify every driver
where it is applicable, as there is no existing common API.

Note that this doesn't include *every* ethernet driver, although there
certainly are some examples.  There are also a number of serious
vendors, providing vendor supported drivers for cards with no known
issues of this kind.

Where exactly would you like to see this implemented if it isn't going
into those specific usbnet drivers?


Bjørn
