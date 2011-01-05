From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Wed, 5 Jan 2011 15:40:28 +0200
Message-ID: <20110105134028.GA9620@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <20110105114155.GN19804@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110105114155.GN19804-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 05, 2011 at 11:41:55AM +0000, Al Viro wrote:
> On Wed, Dec 29, 2010 at 03:14:18PM +0200, Kirill A. Shutemov wrote:
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> 
> Won't that make sunrpc impossible to rmmod once you've got it in?

Oops.. Nice catch.

I'll fix it by relacing remaing references of init_rpc_pipefs with
get_rpc_pipefs(NULL) at the end of the patchset and move init_rpc_pipefs
mounting to get_rpc_pipefs(). So, we will have temporary regression in the
middle of the patchset, but I think it's not a problem.

-- 
 Kirill A. Shutemov
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
