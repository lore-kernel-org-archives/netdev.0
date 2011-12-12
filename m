From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 1/4] SUNRPC: use passed network namespace context in rpc_parse_scope_id()
Date: Mon, 12 Dec 2011 20:18:05 +0400
Message-ID: <4EE6293D.2020903@parallels.com>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6> <20111207112016.17273.44510.stgit@localhost6.localdomain6> <20111208204749.GC32505@fieldses.org> <4EE625E1.7000502@parallels.com> <20111212160722.GF18185@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111212160722.GF18185@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

12.12.2011 20:07, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, Dec 12, 2011 at 08:03:45PM +0400, Stanislav Kinsbursky wrote:
>> 09.12.2011 00:47, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Wed, Dec 07, 2011 at 03:20:16PM +0300, Stanislav Kinsbursky wrot=
e:
>>>> Use incomming network context in rpc_parse_scope_id() instead of h=
ard-coded
>>>
>>> Changelogs are a little confusing; I might have said "allow
>>> rpc_parse_cope_id() caller to pass in network context instead of us=
ing
>>> hard-code "init_net"."
>>
>> Probably, you variant is better. My English is not good enough to
>> write descriptive and, in the same time, clear and short comments to
>> patches.
>
> Uh, and mine's got a problm or two as well.  ("hard-code" should be
> "hard-coded" in the above.)
>
> My main complaint was just that "incoming network context" sounds lik=
e
> it refers to the network context associated with an incoming rpc
> request.  But actually all you're doing is using the network context
> passed in by the caller.
>
> --b.

Yep, agreed.
I'll resend next patch set version with better comments.

--=20
Best regards,
Stanislav Kinsbursky
