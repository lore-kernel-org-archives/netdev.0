From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 05/10] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Thu, 6 Sep 2012 15:23:54 -0700
Message-ID: <20120906222354.GQ29092@google.com>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
 <1345816904-21745-6-git-send-email-wagi@monom.org>
 <20120824232840.GS21325@google.com>
 <5039046D.1040402@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5039046D.1040402-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Daniel.

On Sat, Aug 25, 2012 at 06:59:25PM +0200, Daniel Wagner wrote:
> >Wouldn't it be better to explicitly state that a following patch would
> >reduce the SUBSYS_COUNT and stop putting builtin and module ones into
> >different sections?
> 
> Sure, can do that. I just to make sure I understand you correctly,
> What do you mean with different section? Do you refer to the enum sorting?

I meant that there's no reason to have all builtin ones contiguosly
and then the module ones using two cgroup_subsys.h inclusions.

Thanks!

-- 
tejun
