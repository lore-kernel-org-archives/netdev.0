From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 0/3] Send audit/procinfo/cgroup data in socket-level
 control message
Date: Wed, 4 Sep 2013 11:20:22 -0400
Message-ID: <20130904152022.GD28517@madcap2.tricolour.ca>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
 <1378275261-4553-1-git-send-email-jkaluza@redhat.com>
 <878uzdf2xp.fsf@xmission.com>
 <20130904145830.GC28517@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130904145830.GC28517-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 04, 2013 at 10:58:30AM -0400, Richard Guy Briggs wrote:
> On Wed, Sep 04, 2013 at 12:42:26AM -0700, Eric W. Biederman wrote:
> > Jan Kaluza <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> > > this patchset against net-next (applies also to linux-next) adds 3 new types
> > > of "Socket"-level control message (SCM_AUDIT, SCM_PROCINFO and SCM_CGROUP).
> 
> > By my count you have overflowed cb in struct sk_buff and are stomping on
> > _skb_refdest.
> 
> For patch1/3 I count 56/48, then for patch3 I get 48/48.  Jan, you might
> do the conversion to a pointer in patch1/3 to avoid bisect breakage.

Wait, that __aligned(8) is for cb[48], not for the contents.

For patch1/3 I count 28/48 on 32-bit, 36/48 on 64-bit (or would that be
56 by default on 64-bit arches without aligned specified?), then for
patch3 I get 24/48 on 32 and 40/48 on 64 (or again 48/48 by default?).

> > Eric
> 
> - RGB

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer
Kernel Security
AMER ENG Base Operating Systems
Remote, Ottawa, Canada
Voice: +1.647.777.2635
Internal: (81) 32635
Alt: +1.613.693.0684x3545
