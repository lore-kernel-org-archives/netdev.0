From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 6/6] SUNRPC: split SUNPRC PipeFS dentry and private pipe
 data creation
Date: Mon, 26 Dec 2011 14:45:56 +0400
Message-ID: <4EF85064.6040907@parallels.com>
References: <20111122134514.479.9848.stgit@localhost6.localdomain6>	 <20111122144215.479.20931.stgit@localhost6.localdomain6> <1324819019.5195.4.camel@lade.trondhjem.org>
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
In-Reply-To: <1324819019.5195.4.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

25.12.2011 17:16, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> @@ -387,7 +397,9 @@ nfs_idmap_delete(struct nfs_client *clp)
>> >
>> >         if (!idmap)
>> >                 return;
>> >  -     rpc_unlink(idmap->idmap_dentry);
>> >  +     if (idmap->idmap_pipe->dentry)
> Shouldn't this be a test for IS_ERR(idmap->idmap_pipe->dentry)?
>

Nope. This dentry is either NULL or valid pointer.
Will resend rebased version soon.

--=20
Best regards,
Stanislav Kinsbursky
