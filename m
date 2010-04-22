From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Bug#577640: linux-image-2.6.33-2-amd64: Kernel warnings in netns  thread
Date: Wed, 21 Apr 2010 19:38:13 -0700
Message-ID: <m1sk6oky96.fsf@fess.ebiederm.org>
References: <20100413112017.8505.36380.reportbug@japot.localdomain>
	<1271612005.3679.248.camel@localhost>
	<o2jb9800b71004210819t6ca61099y17be143527ccbc95@mail.gmail.com>
	<m1ljcgzjh4.fsf@fess.ebiederm.org> <1271895278.2582.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>,
	577640@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49279 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab0DVCiV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 22:38:21 -0400
In-Reply-To: <1271895278.2582.3.camel@localhost> (Ben Hutchings's message of "Thu\, 22 Apr 2010 01\:14\:38 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> writes:

> On Wed, 2010-04-21 at 12:36 -0700, Eric W. Biederman wrote:
>> Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:
>>=20
>> > I'm not starting a new thread/bug, as this is probably related...
>> >
>> > I just discovered that in 2.6.33, if I create a veth inside a
>> > namespace and then move one of the halves into the main namespace,
>> > when I kill the namespace, I get one of these warnings followed by=
 an
>> > oops. This does not happen if the veth is created from the main ns=
 and
>> > then moved, nor in 2.6.32. This happens both in Qemu and on real
>> > hardware (both amd64)
>> >
>> > To reproduce:
>> >
>> > $ sudo ./startns bash
>> > # ip l a type veth
>> > # ip l s veth0 netns 1
>> > # exit
>>=20
>> Nasty weird. I did a quick test here, and I'm not seeing that.
>> Does the 2.6.33 experimental kernel have any patches applied?
>
> Yes, but not many beyond the stable updates, and nothing in this area=
=2E
> You can see the list at:
> http://svn.debian.org/wsvn/kernel/dists/trunk/linux-2.6/debian/patche=
s/series/base

Then I should ask what is startns?

Either that is doing something different from my equivalent program, or=
 I have
patches to fix this, that just haven't been merged yet.

Eric
