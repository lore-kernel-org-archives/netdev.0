From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH 1/5] tun check error on memcpy_fromiovec
Date: Fri, 16 Jan 2004 16:45:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116164512.C19034@osdlab.pdx.osdl.net>
References: <20031208202302.C30587@build.pdx.osdl.net> <20031219103457.GD1213@mail.sternwelten.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maximilian attems <janitor@sternwelten.at>
Content-Disposition: inline
In-Reply-To: <20031219103457.GD1213@mail.sternwelten.at>; from janitor@sternwelten.at on Fri, Dec 19, 2003 at 11:34:58AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* maximilian attems (janitor@sternwelten.at) wrote:
> hey chris,
> 
> after applying your 4 patches on top of linux-2.6.0 
> + experimental net, 
> found 2 last unchecked memcpy_fromiovec in tun.c
> patch bellow fixes the second call, 
> the first is beyond me, please complete this patch :)
> compile tested

I specifically left those alone.  They have a semi-bogus verify_area()
call that is trying to insure the memcpy_fromiovec won't EFAULT.  I'd
prefer to remove them and simply do memcpy checking.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
