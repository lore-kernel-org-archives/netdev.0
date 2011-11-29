From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 12:27:02 -0500
Message-ID: <20111129172702.GB19528@fieldses.org>
References: <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com>
 <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
 <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com>
 <1322579906.3619.1.camel@lade.trondhjem.org>
 <CA+a=Yy6kJe0NemSiRwM+t8gz5-UF5fOdwdS2so+q=nSYjBx--w@mail.gmail.com>
 <1322584830.4174.16.camel@lade.trondhjem.org>
 <20111129164252.GA19528@fieldses.org>
 <1322587165.4174.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peng Tao <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, tao.peng-mb1K0bWo544@public.gmane.org,
	skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1322587165.4174.20.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 12:19:25PM -0500, Trond Myklebust wrote:
> On Tue, 2011-11-29 at 11:42 -0500, J. Bruce Fields wrote: 
> > On Tue, Nov 29, 2011 at 11:40:30AM -0500, Trond Myklebust wrote:
> > > I mean that I'm perfectly entitled to do
> > > 
> > > 'modprobe -r blocklayoutdriver'
> > > 
> > > and when I do that, then I expect blkmapd to close the rpc pipe and wait
> > > for a new one to be created just like rpc.idmapd and rpc.gssd do when I
> > > remove the nfs and sunrpc modules.
> > 
> > The rpc pipefs mount doesn't hold a reference on the sunrpc module?
> 
> I stand corrected: the mount does hold a reference to the sunrpc
> module. 
> However nothing holds a reference to the blocklayoutdriver module, so
> the main point that the "blocklayout" pipe can disappear from underneath
> the blkmapd stands.

OK, that makes sense.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
