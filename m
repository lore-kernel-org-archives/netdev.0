From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Partial revert
 "Basic kernel memory functionality for the Memory Controller"
Date: Mon, 26 Dec 2011 18:32:07 +0900
Message-ID: <20111226183207.1c40b8f4.kamezawa.hiroyu@jp.fujitsu.com>
References: <1324543990-27784-1-git-send-email-glommer@parallels.com>
	<20111222104339.GA8833@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>,
	Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>,
	Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111222104339.GA8833-VqjxzfR4DlwKmadIfiO5sKVXKuFTiq87@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Dec 2011 11:43:39 +0100
Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:

> On Thu 22-12-11 12:53:10, Glauber Costa wrote:
> > This reverts commit e5671dfae59b165e2adfd4dfbdeab11ac8db5bda.
> > 
> > After a follow up discussion with Michal, it was agreed it would
> > be better to leave the kmem controller with just the tcp files,
> > deferring the behavior of the other general memory.kmem.* files
> > for a later time, when more caches are controlled.
> 
> "Because generic kmem files are not used by tcp accounting and it is
> not clear how other slab caches would fit into the scheme."
> 
> > 
> > We are reverting the original commit so we can track the reference.
> > Part of the patch is kept, because it was used by the later tcp
> > code. Conflicts are shown in the bottom. init/Kconfig is removed from
> > the revert entirely.
> > 
> > Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> > CC: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > CC: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> > CC: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > CC: Johannes Weiner <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > CC: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> > CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> 
> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
