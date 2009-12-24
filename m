From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
Date: Thu, 24 Dec 2009 01:13:23 -0500
Message-ID: <20091224061322.GB24396@heat>
References: <m13a38uqc4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Michael Stone <michael@laptop.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m13a38uqc4.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Eric Biederman writes:
>> Alan Cox <alan@lxorguk.ukuu.org.uk> writes:
>>> Michael Stone writes:
>>>> the LSM-based version *does not* resolve the situation to my satisfaction as a
>>>> userland hacker due to the well-known and long-standing adoption and
>>>> compositionality problems facing small LSMs. ;)
>>>
>>> For things like Fedora it's probably an "interesting idea, perhaps we
>>> should do it using SELinux" sort of problem, but a config option for a
>>> magic network prctl is also going to be hard to adopt without producing a
>>> good use case - and avoiding that by dumping crap into everyones kernel
>>> fast paths isn't a good idea either.
>
>If I understand the problem the goal is to disable access to ipc
>mechanism that don't have the usual unix permissions.  To get
>something that is usable for non-root processes, and to get something
>that is widely deployed so you don't have to jump through hoops in
>end user applications to use it.

Eric,

You understand correctly. Thank you for this cogent restatement.

>We have widely deployed mechanisms that are what you want or nearly
>what you want already in the form of the various namespaces built for
>containers.

It's true that your work is closer to what I want than anything else that I've
seen so far...

>I propose you introduce a permanent disable of executing suid 
>applications. 

I'm open to the idea but I don't understand the need that motivates it yet.

Could you please explain further? (or point me to an existing explanation?)

>After which point it is another trivial patch to allow unsharing of
>the network namespace if executing suid applications are disabled.

How do you propose to address the problem with the Unix sockets?

Regards,

Michael
