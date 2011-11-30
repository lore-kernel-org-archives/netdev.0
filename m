From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v7 01/10] Basic kernel memory functionality for the
 Memory Controller
Date: Wed, 30 Nov 2011 09:48:51 +0900
Message-ID: <20111130094851.ae55f7fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org,
	lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org, avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org" <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322611021-1730-2-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Nov 2011 21:56:52 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> This patch lays down the foundation for the kernel memory component
> of the Memory Controller.
> 
> As of today, I am only laying down the following files:
> 
>  * memory.independent_kmem_limit
>  * memory.kmem.limit_in_bytes (currently ignored)
>  * memory.kmem.usage_in_bytes (always zero)
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Reviewed-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> CC: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> CC: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Now, there are new memcg maintainers as

Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

So, please CC them.
I may not be able to make a quick/good reply.

Hmm, my concern is

+ memory.independent_kmem_limit	 # select whether or not kernel memory limits are
+				   independent of user limits

I'll be okay with this. other ones ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
