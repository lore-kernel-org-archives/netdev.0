From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: warnings in git-wireless
Date: Wed, 6 Jun 2007 17:00:58 -0700
Message-ID: <20070606170058.57e70102.randy.dunlap@oracle.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
	<46671E5D.9070304@linux.intel.com>
	<20070606163534.6a6cffb7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070606163534.6a6cffb7.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Jun 2007 16:35:34 -0700 Andrew Morton wrote:

> On Wed, 06 Jun 2007 13:51:41 -0700 James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> 
> > 
> > >>  * make C=2 CF=-Wall will complain if you use ARRAY_SIZE on global data
> > >>  */
> > >> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
> > > 
> > > This is identical to ARRAY_SIZE.
> > >
> > > And if there's some problem with ARRAY_SIZE then fix ARRAY_SIZE!  Don't go 
> > > off and create some private thing and leave everyone else twisting in the
> > > wind.
> > 
> > The code was resolving the sparse warnings.  GLOBAL_ARRAY_SIZE removes the part of the ARRAY_SIZE definition that causes sparse to complain ('+ __must_be_array(arr)').  I don't know enough about how sparse works to fix sparse, or to know if its a problem with __must_be_array.  The code itself was fine -- using an array with ARRAY_SIZE.
> 
> (These 340-column emails are rather hard to reply to)
> 
> Your GLOBAL_ARRAY_SIZE() is, afaict, identical to ARRAY_SIZE().
> 
> If ARRAY_SIZE() is spitting some sparse warning then please report it and
> we'll take a look into it.

Looks like a sparse problem.  See
  http://marc.info/?l=linux-sparse&m=118105261224378&w=2


> > Agreed; iwlwifi should be using lib/hexcump.c
> 
> The hexdump.c interfaces are about to change, so I wouldn't do anything
> with this until after 2.6.23-rc1.

James, hexdump.c changes are already in 2.6.22-rc4-mm1 just in case
you want to see them.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
