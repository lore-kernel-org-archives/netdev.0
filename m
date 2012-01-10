From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Tue, 10 Jan 2012 14:50:10 +0400
Message-ID: <4F0C17E2.6030003@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6> <1325285705.10984.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325285705.10984.4.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

31.12.2011 02:55, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 2011-11-29 at 13:10 +0300, Stanislav Kinsbursky wrote:
>> This patch set was created in context of clone of git
>> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>> tag: v3.1
>>
>> This patch set depends on previous patch sets titled:
>> 1) "SUNRPC: initial part of making pipefs work in net ns"
>> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
>> 3) "SUNRPC: make RPC clients use network-namespace-aware PipeFS rout=
ines"
>> 4) "NFS: create clients and IDMAP pipes per network namespace"
>>
>> This patch set is the final part of making SUNRPC PipeFS and it's us=
ers work in
>> network namespace context.
>>
>> The following series consists of:
>>
>> ---
>>
>> Stanislav Kinsbursky (5):
>>        NFS: handle blocklayout pipe PipeFS dentry by network namespa=
ce aware routines
>>        NFS: blocklayout pipe creation per network namespace context =
introduced
>>        NFS: blocklayout PipeFS notifier introduced
>>        NFS: remove RPC PipeFS mount point reference from blocklayout=
 routines
>>        SUNRPC: kernel PipeFS mount point creation routines removed
>>
>>
>>   fs/nfs/blocklayout/blocklayout.c    |  154 +++++++++++++++++++++++=
+++++-------
>>   fs/nfs/blocklayout/blocklayout.h    |    3 -
>>   fs/nfs/blocklayout/blocklayoutdev.c |    5 +
>>   fs/nfs/blocklayout/blocklayoutdm.c  |    7 +-
>>   fs/nfs/inode.c                      |    1
>>   fs/nfs/netns.h                      |    1
>>   include/linux/sunrpc/rpc_pipe_fs.h  |    2
>>   net/sunrpc/rpc_pipe.c               |   21 -----
>>   8 files changed, 137 insertions(+), 57 deletions(-)
>
>
> These patches need rebasing in order to apply on top of 3.2-rc7...
>

Will resend rebased version soon.

--=20
Best regards,
Stanislav Kinsbursky
