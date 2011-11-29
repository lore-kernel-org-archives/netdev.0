From: Peng Tao <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 23:10:16 +0800
Message-ID: <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tao.peng-mb1K0bWo544@public.gmane.org, skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23-hX7t0kiaRRrlMGe9HJ1VYQK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 9:35 PM, Myklebust, Trond
<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org> wrote:
>> -----Original Message-----
>> From: tao.peng-mb1K0bWo544@public.gmane.org [mailto:tao.peng-mb1K0bWo544@public.gmane.org]
>> Sent: Tuesday, November 29, 2011 7:40 AM
>> To: skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
>> Cc: Myklebust, Trond; linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org=
;
>> neilb-l3A5Bk7waGM@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>> jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org;
>> devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
>> Subject: RE: [PATCH 4/5] NFS: remove RPC PipeFS mount point referenc=
e
>> from blocklayout routines
>>
>> > -----Original Message-----
>> > From: Stanislav Kinsbursky [mailto:skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org]
>> > Sent: Tuesday, November 29, 2011 8:19 PM
>> > To: Peng, Tao
>> > Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org; linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Pavel
>> > Emelianov; neilb-l3A5Bk7waGM@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>> > linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; James Bottomley; bfields-uC3wQj2KruMpug/h7KTFAQ@public.gmane.org=
g;
>> > davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
>> > Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point refere=
nce
>> > from blocklayout routines
>> >
>> > 29.11.2011 16:00, tao.peng-mb1K0bWo544@public.gmane.org =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> > >> -----Original Message-----
>> > >> From: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> > >> [mailto:linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of
>> > Stanislav
>> > >> Kinsbursky
>> > >> Sent: Tuesday, November 29, 2011 6:11 PM
>> > >> To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
>> > >> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; neilb@suse.=
de;
>> > >> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux- kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
>> > >> jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org;
>> > >> davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
>> > >> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point referen=
ce
>> > >> from blocklayout routines
>> > >>
>> > >> This is a cleanup patch. We don't need this reference anymore,
>> > >> because blocklayout pipes dentries now creates and destroys in
>> > >> per-net operations and on PipeFS mount/umount notification.
>> > >> Note that nfs4blocklayout_register_net() now returns 0 instead =
of
>> > >> -ENOENT in case of PipeFS superblock absence. This is ok, becau=
se
>> > >> blocklayout pipe dentry will be created on PipeFS mount event.
>> > > When is the "pipefs mount event" going to happen? When inserting
>> > > kernel modules or when user issues
>> > mount command?
>> > >
>> >
>> > When user issues mount command.
>> > Kernel mounts of PipeFS has been removed with all these patch sets
>> > I've sent already.
>> Then it is going to break blocklayout user space program blkmapd, wh=
ich is
>> stared before mounting any file system and it tries to open the pipe=
 file
>> when started.
>
> Why on earth is blkmapd doing this instead of listening for file crea=
tion notifications like the other rpc_pipefs daemons do?
Not sure how the original implementer chose this but I think it is
likely because we do not expect the pipe file to be created or deleted
dynamically.

--=20
Thanks,
Tao
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
