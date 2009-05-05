From: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
	synchronization, v5
Date: Mon, 4 May 2009 17:55:39 -0700
Message-ID: <20090505005539.GG29124@cuplxvomd02.corp.sa.net>
References: <1241272876.3639.27.camel@mulgrave.int.hansenpartnership.com> <Pine.LNX.4.44L0.0905021335150.26241-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0905021335150.26241-100000-pYrvlCTfrz9XsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 02, 2009 at 01:55:45PM -0400, Alan Stern wrote:
> On Sat, 2 May 2009, James Bottomley wrote:
...
> > What I'm getting at is that I don't see the benefit of this in the light
> > of Arjan's async boot system, which can also tell us when all discovery
> > is complete ... what added benefit am I missing here?
> 
> How does Arjan's async boot system tell use when all discovery is
> complete?  AFAICS, it only tells you when all its async tasks are
> finished.  But device discovery and registration sometimes use other
> asynchronous techniques which Arjan's code is unaware of.  Examples:  
> the USB khubd thread, the USB mass-storage scanning thread, and the
> SCSI async-scanning thread.

The patchset does use Arjan's asynchronous function calls in one place.  If
there are other places it can be used to get equivalent functionality, I'll
be happy to do so.

> Alan Stern

David VomLehn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
