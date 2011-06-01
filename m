From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure
 counters
Date: Wed, 1 Jun 2011 22:07:03 +0200
Message-ID: <20110601200702.GC2784@psychotron.redhat.com>
References: <4DE63E85.7020508@redhat.com>
 <20110601135321.GA2909@psychotron.brq.redhat.com>
 <16056.1306944819@death>
 <20110601.120300.130602301077156524.davem@davemloft.net>
 <4DE68ECB.70802@redhat.com>
 <4DE69455.3080203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42983 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab1FAUHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 16:07:24 -0400
Content-Disposition: inline
In-Reply-To: <4DE69455.3080203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2011 at 09:34:45PM CEST, nicolas.2p.debian@gmail.com wrote=
:
>Le 01/06/2011 21:11, Flavio Leitner a =E9crit :
>>On 06/01/2011 04:03 PM, David Miller wrote:
>>>From: Jay Vosburgh<fubar@us.ibm.com>
>>>Date: Wed, 01 Jun 2011 09:13:39 -0700
>>>
>>>>	The "this dingus was added in version X.Y.Z" is there because
>>>>users sometimes read the most recent version of the documentation (=
that
>>>>they get from the internet) and then would become confused when the=
ir
>>>>older distro driver lacked some option described in the documentati=
on.
>>>
>>>I disagree with this whole concept, because distros backport feature=
s
>>>like this into their kernel and therefore the feature is showing up =
in
>>>version X.Y.$(Z-20).
>>
>>It doesn't matter the version if the user can find the feature, so
>>distros backporting features works and that info is not useful at all=
=2E
>>However, when the user doesn't find the feature and search the intern=
et,
>>then that info is helpful.
>
>There are *many* new features that get included into the kernel
>without documenting the exact first version that provide them. Why
>should we need this for bonding? Also, because we lack a table that
>gives the kernel version matching a bonding version, the user is not
>really helped by "you need version X.Y.Z of bonding to have this
>feature".


I think that doing versioning on multiple parts of the same code is onl=
y
confusing. Kernel version should be only version for whole kernel code.
Changes should be only documented in descriptions of changesets. Any
other way is redundant, might be not accurate, and rather confusing.

Jirka

>
>So, I'm not sure it helps...
>
>	Nicolas.
