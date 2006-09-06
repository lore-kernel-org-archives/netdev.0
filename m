From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 14:40:13 -0600
Message-ID: <m1hczkvidu.fsf@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<20060816115313.GC31810@sergelap.austin.ibm.com>
	<44FD7CF0.4030009@fr.ibm.com>
	<m1k64i1br2.fsf@ebiederm.dsl.xmission.com>
	<44FF2EA6.2030303@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serue@us.ibm.com>, Andrey Savochkin <saw@sw.ru>,
	haveblue@us.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:30688 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1751188AbWIFUl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 16:41:28 -0400
To: Cedric Le Goater <clg@fr.ibm.com>
In-Reply-To: <44FF2EA6.2030303@fr.ibm.com> (Cedric Le Goater's message of
	"Wed, 06 Sep 2006 22:25:10 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

> Eric W. Biederman wrote:
>
> hmm ? What about an MPI application ?
>
> I would expect each MPI task to be run in its container on different nodes
> or on the same node. These individual tasks _communicate_ between each
> other through the MPI layer (not only TCP btw) to complete a large calculation.

All parts of the MPI application are part of the same job.  Communication between
processes on multiple machines that are part of the job is fine.

At least that is how I used job in HPC computer context.

Eric
