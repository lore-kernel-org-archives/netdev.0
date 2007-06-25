From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [2/2] 2.6.22-rc6: known regressions with patches
Date: Mon, 25 Jun 2007 11:27:32 -0700 (PDT)
Message-ID: <alpine.LFD.0.98.0706251126040.3593@woody.linux-foundation.org>
References: <467F894C.4000604@googlemail.com>
 <467F8F63.2070101@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Antonino Daplas <adaplas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Olaf Hering <olaf-QOLJcTWqO2uzQB+pC5nmwQ@public.gmane.org>, Ville Syrj?l? <syrjala-ORSVBvAovxo@public.gmane.org>,
	Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>,
	Dave Airlie <airlied-cv59FeDIM0c@public.gmane.org>,
	Andrea Righi <righiandr-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>,
	Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>,
	Chad Tindel <ctindel-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Olaf Hering <olaf-QOLJcTWqO2uzQB+pC5nmwQ@public.gmane.org>
To: Michal Piotrowski <michal.k.k.piotrowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <467F8F63.2070101-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Mon, 25 Jun 2007, Michal Piotrowski wrote:
> 
> Memory management
> 
> Subject    : bug in i386 MTRR initialization
> References : http://lkml.org/lkml/2007/5/19/93
> Submitter  : Andrea Righi <righiandr-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Status     : patch available

This one wasn't a bug in the first place, it was just the regular warning 
for kmalloc-size-0. The "BUG" string was confusing and has been fixed, and 
the warning for size-0 has gone away and been replaced by returning a 
pointer that will fault on dereference instead.

So please remove this one.

		Linus
