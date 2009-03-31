From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference counting.
Date: Tue, 31 Mar 2009 01:47:29 -0700
Message-ID: <m1y6umcc4e.fsf@fess.ebiederm.org>
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
	<1238487045.28248.1774.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu,
	jbeulich@novell.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, linux-kernel@vger.kernel.org, ego@in.ibm.com,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38938 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbZCaIrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:47:40 -0400
In-Reply-To: <1238487045.28248.1774.camel@twins> (Peter Zijlstra's message of "Tue\, 31 Mar 2009 10\:10\:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra <peterz@infradead.org> writes:

> On Mon, 2009-03-30 at 15:26 -0700, Andrew Morton wrote:
>> So I merged these two patches.  I designated them as to-be-merged via
>> Alexey, with a Cc:Peter (IOW: wakey wakey ;))
>
> Ah, I was under the impression they weren't quite finished yet,
> apparently I was mistaken.
>
> Eric, didn't you need recursive locks fixed and such?

In theory.  In practice I removed the one case that could legitimately
recurse.

> Let me have a look at them.
