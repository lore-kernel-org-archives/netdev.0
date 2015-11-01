From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] isdn: Use ktime_t instead of 'struct timeval'
Date: Sun, 01 Nov 2015 16:15:33 -0500 (EST)
Message-ID: <20151101.161533.1975473410924274976.davem@davemloft.net>
References: <20151030040816.GA3085@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, isdn@linux-pingi.de,
	linux-kernel@vger.kernel.org
To: ruchandani.tina@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151030040816.GA3085@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Ruchandani <ruchandani.tina@gmail.com>
Date: Thu, 29 Oct 2015 21:08:16 -0700

> @@ -45,7 +46,7 @@ static u_int *debug;
>  static LIST_HEAD(iclock_list);
>  static DEFINE_RWLOCK(iclock_lock);
>  static u16 iclock_count;		/* counter of last clock */
> -static struct timeval iclock_tv;	/* time stamp of last clock */
> +static ktime_t iclock_tv;		/* time stamp of last clock */
>  static int iclock_tv_valid;		/* already received one timestamp */

It only makes sense for this variable to be named "iclock_tv" when
it is of type "timeval".  And therefore it is confusing to keep
using this variable name after changing it's type to "ktime_t".

Therefore please adjust the variable name appropriately, thanks.
