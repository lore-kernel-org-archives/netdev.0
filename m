From: Chase Venters <chase.venters@clientec.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Tue, 13 Jun 2006 17:00:53 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0606131655580.4856@turbotaz.ourhouse>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com>
 <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org>
 <448F2A49.5020809@google.com> <20060613154031.A6276@openss7.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Daniel Phillips <phillips@google.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932356AbWFMWA5@vger.kernel.org>
To: "Brian F. G. Bidulock" <bidulock@openss7.org>
In-Reply-To: <20060613154031.A6276@openss7.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jun 2006, Brian F. G. Bidulock wrote:

> Daniel,
>
> On Tue, 13 Jun 2006, Daniel Phillips wrote:
>>
>> This has the makings of a nice stable internal kernel api.  Why do we want
>> to provide this nice stable internal api to proprietary modules?
>
> Why not?  Not all non-GPL modules are proprietary.  Do we lose
> something by making a nice stable api available to non-derived
> modules?

Look out for that word (stable). Judging from history (and sanity), 
arguing /in favor of/ any kind of stable module API is asking for it.

At least some of us feel like stable module APIs should be explicitly 
discouraged, because we don't want to offer comfort for code 
that refuses to live in the tree (since getting said code into the tree is 
often a goal).

I'm curious now too - can you name some non-GPL non-proprietary modules we 
should be concerned about? I'd think most of the possible examples (not 
sure what they are) would be better off dual-licensed (one license 
being GPL) and in-kernel.

Thanks,
Chase
