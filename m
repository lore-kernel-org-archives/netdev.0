From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference counting.
Date: Mon, 30 Mar 2009 16:50:17 -0700
Message-ID: <m1iqlqfu4m.fsf@fess.ebiederm.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	<m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
	<m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	<m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
	<20090330152616.7cc2c87c.akpm@linux-foundation.org>
	<m1k566k4hb.fsf@fess.ebiederm.org>
	<20090330161858.18951f62.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, jbeulich@novell.com, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
	ego@in.ibm.com, peterz@infradead.org, adobriyan@gmail.com,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41313 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827AbZC3XuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 19:50:25 -0400
In-Reply-To: <20090330161858.18951f62.akpm@linux-foundation.org> (Andrew Morton's message of "Mon\, 30 Mar 2009 16\:18\:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Mon, 30 Mar 2009 15:53:04 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Andrew Morton <akpm@linux-foundation.org> writes:
>> 
>> > So I merged these two patches.  I designated them as to-be-merged via
>> > Alexey, with a Cc:Peter (IOW: wakey wakey ;))
>> 
>> It is more sysctl than proc but whichever.  As long as people aren't
>> blind sided at the last minute I'm fine.
>
> Yep.  But keeping all fs/proc/ changes in Alexey's tree keeps things
> neat and is part of my secret maintainer-impressment plot.

Sounds like a plan.  You work on that.  I will work on undermining
the plot by breaking /proc into it's several separate filesystems.

> OK, fine, but to avoid confusion and to overtly announce this
> preference, please do add the From: Line?

Sounds like a plan.  In truth I have been deleting that line from my
patches anyway....  It just seemed silly to have it in there when
the real From matched.

Eric

