From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] sysctl:  lockdep support for sysctl reference
 counting.
Date: Tue, 31 Mar 2009 10:10:45 +0200
Message-ID: <1238487045.28248.1774.camel@twins>
References: <49B91A7E.76E4.0078.0@novell.com>
	 <tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	 <1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	 <1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	 <m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	 <m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	 <1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
	 <m1iqm3xr2n.fsf_-_@fess.ebiederm.org> <m1eiwrxr05.fsf_-_@fess.ebiederm.org>
	 <m1ab7fxqxw.fsf_-_@fess.ebiederm.org>
	 <20090330152616.7cc2c87c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, mingo@elte.hu,
	jbeulich@novell.com, tglx@linutronix.de, mingo@redhat.com,
	hpa@zytor.com, linux-kernel@vger.kernel.org, ego@in.ibm.com,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33418 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbZCaIKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:10:44 -0400
In-Reply-To: <20090330152616.7cc2c87c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-03-30 at 15:26 -0700, Andrew Morton wrote:
> So I merged these two patches.  I designated them as to-be-merged via
> Alexey, with a Cc:Peter (IOW: wakey wakey ;))

Ah, I was under the impression they weren't quite finished yet,
apparently I was mistaken.

Eric, didn't you need recursive locks fixed and such?

Let me have a look at them.
