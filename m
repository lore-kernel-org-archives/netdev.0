From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Move an interface to init_ne
Date: Wed, 28 Nov 2012 10:28:43 -0600
Message-ID: <87hao9elok.fsf@xmission.com>
References: <CAJJAcodehJ3x2ZjOuoaV=KrWHH23013b3O20nqh0E1smFvFpHw@mail.gmail.com>
	<CAChaegnKhq50mS+T7XrP9A1hYZbT7c+WGD=tUpWtUY2c-ngb7w@mail.gmail.com>
	<CAJJAcofHM+D8_2u-w5jPJZKfeA0A7QOxX1gxTQ2vOgx-L9aZhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Renato Westphal <renatowestphal@gmail.com>, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41989 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512Ab2K1Q2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:28:51 -0500
In-Reply-To: <CAJJAcofHM+D8_2u-w5jPJZKfeA0A7QOxX1gxTQ2vOgx-L9aZhQ@mail.gmail.com>
	(David Shwatrz's message of "Wed, 28 Nov 2012 17:31:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz <dshwatrz@gmail.com> writes:

> But when I run "modprobe 8139too" on namespace1, a device named "eth1"
> is created on the initial network namespace and not on namesapce1.
> I expected that in such a case, a device named "eth0" will be created
> on namespace1, since it was called from namespace1. Or maybe modprobe
> does
> not consider the namespace from which it was called ?

modprobe has no concept of the namespace from which it was called.

Eric
