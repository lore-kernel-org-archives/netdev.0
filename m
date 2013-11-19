From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] nsproxy: Check to make sure count is truly zero before
 freeing
Date: Mon, 18 Nov 2013 20:59:09 -0500
Message-ID: <20131118205909.6bc27f0e@gandalf.local.home>
References: <20131113160339.7e0726fb@gandalf.local.home>
	<877gc5l3hq.fsf@xmission.com>
	<20131118190457.7ad4e0a0@gandalf.local.home>
	<528ABD6E.8020004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Cedric Le Goater <clg@fr.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Clark Williams <williams@redhat.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.226]:16709 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751064Ab3KSB7M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 20:59:12 -0500
In-Reply-To: <528ABD6E.8020004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Nov 2013 09:22:54 +0800
Gao feng <gaofeng@cn.fujitsu.com> wrote:

> On 11/19/2013 08:04 AM, Steven Rostedt wrote:
> > 
> > I'll start out saying that this email was a complete oops. I only kept
> > it around for reference, as this didn't fix the bug we were seeing, and
> > I used this email to just document what I initially thought.
> > 
> 
> Can you describe the panic situation and the way to reproduce?
> it's useful for us to find out the real problem.
> 

I need to talk with more people to get more information as it happened
in our test labs. From what I remember, it was caused on 3.10-rt (even
with PREEMPT_RT disabled). We are currently testing 3.10 vanilla, to
make sure that it really does occur on mainline.

>From what I understand, it was ltp-lite that caused the panic and it
happened on a box with 16 CPUs.

I'll keep you posted when we get more data that is relevant to mainline.

This is another reason that the email went out prematurely.

-- Steve
