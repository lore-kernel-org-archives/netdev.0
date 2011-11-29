From: Peng Tao <bergwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
Date: Tue, 29 Nov 2011 23:05:33 +0800
Message-ID: <CA+a=Yy7GkbrvB3TsnCQUSnjvEU3DFOA8F8DT7U_xL9BGO2_Rtg@mail.gmail.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
 <20111129091037.20730.59391.stgit@localhost6.localdomain6>
 <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com>
 <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com>
 <4ED4DA80.9080303@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "tao.peng-mb1K0bWo544@public.gmane.org" <tao.peng-mb1K0bWo544@public.gmane.org>,
	"Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED4DA80.9080303-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2011 at 9:13 PM, Stanislav Kinsbursky
<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:
> 29.11.2011 16:40, tao.peng-mb1K0bWo544@public.gmane.org =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>>> -----Original Message-----
>>> From: Stanislav Kinsbursky [mailto:skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org]
>>> Sent: Tuesday, November 29, 2011 8:19 PM
>>> To: Peng, Tao
>>> Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org; linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Pavel
>>> Emelianov; neilb-l3A5Bk7waGM@public.gmane.org;
>>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; James Bottoml=
ey;
>>> bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org;
>>> davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
>>> Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point referen=
ce
>>> from blocklayout routines
>>>
>>> 29.11.2011 16:00, tao.peng-mb1K0bWo544@public.gmane.org =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>>
>>>>> -----Original Message-----
>>>>> From: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>> [mailto:linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org] On Behalf Of
>>>
>>> Stanislav
>>>>>
>>>>> Kinsbursky
>>>>> Sent: Tuesday, November 29, 2011 6:11 PM
>>>>> To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
>>>>> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; neilb-l3A5Bk7waGM@public.gmane.org=
;
>>>>> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
>>>>> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org; bfields@fieldse=
s.org;
>>>>> davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org;
>>>>> devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
>>>>> Subject: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference=
 from
>>>>> blocklayout routines
>>>>>
>>>>> This is a cleanup patch. We don't need this reference anymore, be=
cause
>>>>> blocklayout pipes dentries now creates and destroys in per-net
>>>>> operations and
>>>>> on PipeFS mount/umount notification.
>>>>> Note that nfs4blocklayout_register_net() now returns 0 instead of
>>>>> -ENOENT in
>>>>> case of PipeFS superblock absence. This is ok, because blocklayou=
t pipe
>>>>> dentry
>>>>> will be created on PipeFS mount event.
>>>>
>>>> When is the "pipefs mount event" going to happen? When inserting k=
ernel
>>>> modules or when user issues
>>>
>>> mount command?
>>>>
>>>>
>>>
>>> When user issues mount command.
>>> Kernel mounts of PipeFS has been removed with all these patch sets =
I've
>>> sent
>>> already.
>>
>> Then it is going to break blocklayout user space program blkmapd, wh=
ich is
>> stared before mounting any file system and it tries to open the pipe=
 file
>> when started.
>
>
> Sorry, but I don't get it. Probably we have misunderstanding here.
> You said, that "blkmapd ... tries to open the pipe file when started"=
=2E This
> pipe file is located on PipeFS, isn't it?
> If yes, then PipeFS have to be mounted already in user-space. And if =
it has
> been mounted - then pipe dentry is present.
> IOW, pipe (without dentry) will be created on module load. Pipe dentr=
y will
> be created right after that (like it was before) if PipeFS was mounte=
d from
> user-space. If not - then pipe dentry will be created =C2=A0on PipeFS=
 (!) mount
> (not NFS or pNFS mount) from user-space.
Sorry, I misunderstood. I was thinking about mounting NFS or pNFS when
you say "when user issues mount command". Thanks for the explanation.

Regards,
Tao
>
> Or I'm missing something in your reply?
>
>
>> Not sure if you implement the same logic on nfs pipe as well. But if=
 you
>> do, then nfs client user space program idmapd will fail to start for=
 the
>> same reason.
>>
>
> The same logic here.
>
>
>> Why not just fail to load module if you fail to initialize pipefs? W=
hen is
>> rpc_get_sb_net() going to fail?
>>
>
> Sorry, but I don't understand, what is your idea. And why do we need =
to fail
> at all.
> BTW, rpc_get_sb_net() just checks, was PipeFS mounted in passed net, =
or not.
> If not - not a problem. Dentries will be created on mount event. If y=
es,
> then it returns locked PipeFS sb and the next step is dentry creation=
=2E
>
>
>>>
>>>
>>>> Thanks,
>>>> Tao
>>>>
>>>>>
>>>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>>>>
>>>>> ---
>>>>> =C2=A0 fs/nfs/blocklayout/blocklayout.c | =C2=A0 =C2=A09 +-------=
-
>>>>> =C2=A0 1 files changed, 1 insertions(+), 8 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/blocklayout/blocklayout.c
>>>>> b/fs/nfs/blocklayout/blocklayout.c
>>>>> index acf7ac9..8211ffd 100644
>>>>> --- a/fs/nfs/blocklayout/blocklayout.c
>>>>> +++ b/fs/nfs/blocklayout/blocklayout.c
>>>>> @@ -1032,7 +1032,7 @@ static struct dentry
>>>>> *nfs4blocklayout_register_net(struct net *net,
>>>>>
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0pipefs_sb =3D rpc_get_sb_net(net);
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pipefs_sb)
>>>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ERR_PTR=
(-ENOENT);
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dentry =3D nfs4blocklayout_register_sb=
(pipefs_sb, pipe);
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0rpc_put_sb_net(net);
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0return dentry;
>>>>> @@ -1083,7 +1083,6 @@ static struct pernet_operations
>>>>> nfs4blocklayout_net_ops =3D {
>>>>>
>>>>> =C2=A0 static int __init nfs4blocklayout_init(void)
>>>>> =C2=A0 {
>>>>> - =C2=A0 =C2=A0 =C2=A0 struct vfsmount *mnt;
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
>>>>>
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0dprintk("%s: NFSv4 Block Layout Driver=
 Registering...\n",
>>>>> __func__);
>>>>> @@ -1093,12 +1092,6 @@ static int __init nfs4blocklayout_init(voi=
d)
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out;
>>>>>
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0init_waitqueue_head(&bl_wq);
>>>>> -
>>>>> - =C2=A0 =C2=A0 =C2=A0 mnt =3D rpc_get_mount();
>>>>> - =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(mnt)) {
>>>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D PTR_ER=
R(mnt);
>>>>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_remov=
e;
>>>>> - =C2=A0 =C2=A0 =C2=A0 }
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D rpc_pipefs_notifier_register(&=
nfs4blocklayout_block);
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret)
>>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto out_r=
emove;
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-n=
fs" in
>>>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>>>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-inf=
o.html
>>>>
>>>>
>>>
>>>
>>> --
>>> Best regards,
>>> Stanislav Kinsbursky
>>
>>
>
>
> --
> Best regards,
> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
