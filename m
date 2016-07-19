From: Lars Melin <larsm17@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 15:30:07 +0700
Message-ID: <52d1cd85-8bdc-c8ed-7a2c-460cefe7f0d5@gmail.com>
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
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKfDRXjzgd58kS-MzUsZAsD66VCa5=qyqaLr_eZSm-XphxA7Mw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-07-19 13:40, Kristian Evensen wrote:

> I guess I can match on the VID/PID in usbnet, but won't it be cleaner
> to add a new bind() function (in cdc_ether) which matches the two PIDs
> and leave usbnet as is? Or am I misunderstanding how to add this
> functionality to usbnet?
>

Matching on the usb id is probably not a great idea, there is more id's
than the two you have found and there is also more than two non-unique 
mac addresses.

Example:

0200FFAAAAAA  19d2:1589/1592/1595
020CE70B0102  19d2:1040/1048/1405

You can easily find them by googling them, without colon separators you
will find them in verbose lsusb listings, with colons you will find them 
in dmesg pastings.

I would probably have found more dupes if users had refrained from using 
the stupid usbdevices cmd which removes almost all interesting info from 
device listings in internet foras.

/Lars
