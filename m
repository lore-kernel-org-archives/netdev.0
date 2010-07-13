From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH -mmotm 00/30] [RFC] swap over nfs -v21
Date: Tue, 13 Jul 2010 20:53:43 +0800
Message-ID: <AANLkTil9hGHoomM9LlhURipKO7_sTON09JHP3zDwOLgI@mail.gmail.com>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset-bd3XojVv5Xrm7B5McmCzzQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 13, 2010 at 6:16 PM, Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote=
:
> Hi,
>
> Here's the latest version of swap over NFS series since -v20 last Oct=
ober. We decide to push
> this feature as it is useful for NAS or virt environment.
>
> The patches are against the mmotm-2010-07-01. We can split the patchs=
et into following parts:
>
> Patch 1 - 12: provides a generic reserve framework. This framework
> could also be used to get rid of some of the __GFP_NOFAIL users.
>
> Patch 13 - 15: Provide some generic network infrastructure needed lat=
er on.
>
> Patch 16 - 21: reserve a little pool to act as a receive buffer, this=
 allows us to
> inspect packets before tossing them.
>
> Patch 22 - 23: Generic vm infrastructure to handle swapping to a file=
system instead of a block
> device.
>
> Patch 24 - 27: convert NFS to make use of the new network and vm infr=
astructure to
> provide swap over NFS.
>
> Patch 28 - 30: minor bug fixing with latest -mmotm.
>
> [some history]
> v19: http://lwn.net/Articles/301915/
> v20: http://lwn.net/Articles/355350/
>
> Changes since v20:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- rebased to mmotm-2010-07-01
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- dropped the null pointer deref patch for=
 the root cause is wrong SWP_FILE enum
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- some minor build fixes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- fix a null pointer deref with mmotm-2010=
-07-01
> =C2=A0 =C2=A0 =C2=A0 =C2=A0- fix a bug when swap with multi files on =
the same nfs server

Please use the "From:" line correctly, as stated in
Documentation/SubmittingPatches:

The "from" line must be the very first line in the message body,
and has the form:

        From: Original Author <author-hcDgGtZH8xNBDgjK7y7TUQ@public.gmane.org>

The "from" line specifies who will be credited as the author of the
patch in the permanent changelog.  If the "from" line is missing,
then the "From:" line from the email header will be used to determine
the patch author in the changelog.


I think you are using git format-patch to generate those patches, pleas=
e supply
--author=3D<author> to git commit when you commit them to your local
tree. (or git am
if the patches you received already had the correct From: line.)

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
