From: "Jaswinder Singh Rajput" <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BUG - 2.4.37 fealnx.c NETDEV WATCHDOG: eth0: transmit timed out
Date: Sat, 3 Jan 2009 16:40:29 +0530
Message-ID: <3f9a31f40901030310l211e3ca8hd3c7d2b0e7b18adc@mail.gmail.com>
References: <3f9a31f40901020640m4a9a63caq9c96ba84ccd64d88@mail.gmail.com>
	 <20090102144813.GA13757@1wt.eu>
	 <3f9a31f40901020748m242c46djf153fbab90eeca60@mail.gmail.com>
	 <20090102185718.GB20741@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Willy Tarreau" <w@1wt.eu>, wtarreau-Dj75qbTlC0E76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Francois Romieu" <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090102185718.GB20741-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 3, 2009 at 12:27 AM, Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org> wrote:
> Jaswinder Singh Rajput <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> :
> [..]
>> Output of mii-diag -v :
>> eth0: 10 Mbit, half duplex, no link
>>   product info: vendor 00:00:00, model 0 rev 0
>>   basic mode:   10 Mbit, half duplex
>>   basic status: no link
>>   capabilities:
>>   advertising:
>>
>> This is the output from very old machine Pentium MMX with Redhat 7.1
>
> Can you check with 'mii-tool -vv eth0' that the mii registers are not
> all zeroes ?
>

Yes all are zeros :-)

eth0: 10 Mbit, half duplex, no link
  registers for MII PHY 32:
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
    0000 0000 0000 0000 0000 0000 0000 0000
  product info: vendor 00:00:00, model 0 rev 0
  basic mode:   10 Mbit, half duplex
  basic status: no link
  capabilities:
  advertising:

Now what is next step.

Thank you,
JSR
