From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/9] treewide: convert vprintk uses to %pV
Date: Wed, 10 Nov 2010 14:48:02 -0800
Message-ID: <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T@mail.gmail.com>
References: <cover.1289348757.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1289348757.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 9, 2010 at 4:35 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> Multiple secessive calls to printk can be interleaved.
> Avoid this possible interleaving by using %pV
>
> Joe Perches (9):
> =C2=A0drivers/gpu/drm/drm_stub.c: Use printf extension %pV
> =C2=A0drivers/isdn/mISDN: Use printf extension %pV
> =C2=A0drivers/net/wireless/ath/debug.c: Use printf extension %pV
> =C2=A0drivers/net/wireless/b43/main.c: Use printf extension %pV
> =C2=A0drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
> =C2=A0fs/gfs2/glock.c: Use printf extension %pV
> =C2=A0fs/nilfs2/super.c: Use printf extension %pV
> =C2=A0fs/quota/dquot.c: Use printf extension %pV
> =C2=A0net/sunrpc/svc.c: Use printf extension %pV
>
> =C2=A0drivers/gpu/drm/drm_stub.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 14 +++++++--
> =C2=A0drivers/isdn/mISDN/layer1.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 10 +++++--
> =C2=A0drivers/isdn/mISDN/layer2.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
| =C2=A0 12 ++++++--
> =C2=A0drivers/isdn/mISDN/tei.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| =C2=A0 23 +++++++++++----
> =C2=A0drivers/net/wireless/ath/debug.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A09 +++++-
> =C2=A0drivers/net/wireless/b43/main.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 4=
8 ++++++++++++++++++++++++--------
> =C2=A0drivers/net/wireless/b43legacy/main.c | =C2=A0 47 +++++++++++++=
+++++++++++--------
> =C2=A0fs/gfs2/glock.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +++++-
> =C2=A0fs/nilfs2/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 23 +++++++++++-----
> =C2=A0fs/quota/dquot.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12 +++++---
> =C2=A0net/sunrpc/svc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 12 +++++---
> =C2=A011 files changed, 161 insertions(+), 58 deletions(-)

When was this added upstream BTW? I ask for backport considerations.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
