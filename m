From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] SUNRPC: make SUNPRC clients list per network namespace
 context
Date: Mon, 26 Dec 2011 16:25:06 +0400
Message-ID: <4EF867A2.2020003@parallels.com>
References: <20111214081918.2804.59143.stgit@localhost6.localdomain6> <1324817295.5195.0.camel@lade.trondhjem.org>
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
In-Reply-To: <1324817295.5195.0.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

25.12.2011 16:48, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, 2011-12-14 at 12:19 +0300, Stanislav Kinsbursky wrote:
>> This patch moves static SUNRPC clients list and it's lock to sunrpc_=
net
>> structure.
>> Currently this list is used only for debug purposes. But later it wi=
ll be used
>> also for selecting clients by networks namespace on PipeFS mount/umo=
unt events.
>> Per-network namespace lists will make this faster and simplier.
>>
>> Note: client list is taken from "init_net" network namespace context=
 in
>> rpc_show_tasks(). This will be changed with making SUNRPC sysctl's p=
er network
>> namespace context.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> This doesn't seem to integrate with any of your patch series, and
> conflicts with everything that touches netns.h, for instance...
>

Yep, you are right. Currently this path doesn't apply, if you'll try to=
 apply=20
patches in the same order I've sent them.
This is caused by different development branches.
Anyway, most of the patches will not apply to current tree.
And I'll be glad to rebase and resent them on request.

--=20
Best regards,
Stanislav Kinsbursky
