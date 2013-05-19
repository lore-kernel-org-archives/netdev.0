From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 0/5] drivers: net: usb: rtl8150: bug fixing and code
 cleanup
Date: Sun, 19 May 2013 11:27:29 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305191121400.4537@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305182305110.16874@fry.nucleusys.com> <20130518212013.GA26921@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130518212013.GA26921@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 May 2013, Francois Romieu wrote:

> Petko Manolov <petkan@nucleusys.com> :
> [...]
> > This patch series adds rtl8150.h, which contains structure and constant 
> > definitons formerly found in rtl8150.c, removes socket buffer 
> > pre-allocated pool and uses dynamically allocated memory for the 
> > asynchronous URB requests, thus avoids clobbering the previously scheduled 
> > for update value.
> > 
> > This patch series is against 'net' tree.
> 
> 'net' tree takes fixes. The cleanup / fix ratio is imho a bit high in 
> this series. You may submit the fix part now and wait until davem merges 
> 'net' into 'net-next' to submit big cleanups against net-next.

Well, i did ask which tree to use as a base.  It may seem like a lot, but 
these changes are trivial.  If David decide to schedule the patches for 
3.11 it won't break my heart.


		Petko
