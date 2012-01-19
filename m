From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/5] SUNRPC: make caches network namespace aware
Date: Thu, 19 Jan 2012 19:43:22 +0400
Message-ID: <4F183A1A.1050208@parallels.com>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6> <1326986392.6114.1.camel@lade.trondhjem.org> <4F18376C.9090504@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430CE01EE4@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dr James Bruce Fields <bfields@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430CE01EE4@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.01.2012 19:34, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> -----Original Message-----
>> From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>> Sent: Thursday, January 19, 2012 10:32 AM
>> To: Myklebust, Trond
>> Cc: Dr James Bruce Fields; linux-nfs@vger.kernel.org; Pavel Emeliano=
v;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> James Bottomley; bfields@fieldses.org; davem@davemloft.net;
>> devel@openvz.org
>> Subject: Re: [PATCH 0/5] SUNRPC: make caches network namespace aware
>>
>> 19.01.2012 19:19, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Thu, 2012-01-19 at 18:48 +0400, Stanislav Kinsbursky wrote:
>>>> One more step towards to "NFS in container".
>>>> With this patch set caches are allocated per network namespace.
>>>>
>>>> The following series consists of:
>>>>
>>>> ---
>>>>
>>>> Stanislav Kinsbursky (5):
>>>>         SUNRPC: cache creation and destruction routines introduced
>>>>         SUNRPC: create unix gid cache per network namespace
>>>>         SUNRPC: create GSS auth cache per network namespace
>>>>         SUNRPC: ip map cache per network namespace cleanup
>>>>         SUNRPC: generic cache register routines removed
>>>
>>> The patches look good, and I've applied them for now in my 'devel'
>>> branch so we can test them, but I'd like to get an Ack/Nack from Br=
uce
>>> before committing to merging them.
>>>
>>
>> Cool, thanks.
>> BTW, these patches depends on patch "NFSd: use network-namespace-
>> aware cache registering routines", which Bruce took already (and it'=
s even in
>> linux-next already), but not in your devel tree for some reason.
>
> In that case, would it make more sense to carry them in Bruce's tree?
>

It's up to you, of course.  But, frankly, I don't think so.
To be more precise, only the last patch ("SUNRPC: generic cache registe=
r=20
routines removed") depends on the patch, which is in linux-next already=
=2E IOW,=20
those patch removed NFSd dependence on cache_register() and cache_unreg=
ister()=20
routines and was commited to linux-next at Wed, 7 Dec 2011.


--=20
Best regards,
Stanislav Kinsbursky
