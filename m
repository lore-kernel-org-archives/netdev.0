From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Sun, 4 Mar 2007 16:45:25 -0800
Message-ID: <20070304164525.349f9589.akpm@linux-foundation.org>
References: <20070304220857.GH23311@waste.org>
	<1173051564.6131.13.camel@johannes.berg>
	<20070305002550.GI23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070305002550.GI23311-1tnLUEbcrg3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Mar 2007 18:25:50 -0600 Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:

> On Mon, Mar 05, 2007 at 12:39:24AM +0100, Johannes Berg wrote:
> > [adding linux-wireless to CC]
> > 
> > On Sun, 2007-03-04 at 16:08 -0600, Matt Mackall wrote:
> > > Recent kernels are having troubles with wireless for me. Two seemingly
> > > related problems:
> > 
> > I don't think they are related actually.
> > 
> > > a) NetworkManager seems oblivious to the existence of my IPW2200
> > 
> > This is due to the recent sysfs restructuring I think. IIRC the fix is
> > to upgrade hal to a current git version.
> 
> If that's the cause, the fix is to back out whatever was done to break
> userspace. Breaking userspace is not ok. Upgrading from 2.6.x to
> 2.6.x+1 should not entail replacing substantial parts of userspace,
> especially with NOT-EVEN-FRAKKING-RELEASED-YET CODE. 

yep.  Adrian, I think we should track this as a blocking regression, at
least until we've fully understood the implications and had the usual
arguments.
