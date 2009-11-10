From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Wed, 11 Nov 2009 05:26:39 +0900
Message-ID: <1257884799.3044.7.camel@heimdal.trondhjem.org>
References: <4AF9A63B.6010101@nortel.com>
	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
	 <4AF9B2CF.6050305@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758070AbZKJU0p@vger.kernel.org>
In-Reply-To: <4AF9B2CF.6050305@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 12:37 -0600, Chris Friesen wrote:
> On 11/10/2009 11:53 AM, Ben Hutchings wrote:
> > On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:
> 
> >> Given that a userspace application can be stopped and restarted at any
> >> time, and a sunrpc registration can happen at any time, what is the
> >> expected mechanism to prevent the kernel from allocating a port for use
> >> by sunrpc that reserved or well-known?
> >>
> >> Apparently Redhat and Debian have distro-specific ways of dealing with
> >> this, but is there a standard solution?  Should there be?
> >>
> >> The current setup seems suboptimal.
> > 
> > I believe both RH and Debian are using the same implementation:
> > <http://cyberelk.net/tim/software/portreserve/>.
> 
> That helps with the startup case, but still leaves a possible hole if an
> app using a fixed port number is restarted at runtime.  During the
> window where nobody is bound to the port, the kernel could randomly
> assign it to someone else.

Just use /proc/sys/sunrpc/{max,min}_resvport interface to restrict the
range used to a safer one. That's what it is for...

Trond
