From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG][3.10.15] reading from /proc/sys/net/netfilter/nf_log/*
Date: Wed, 18 Dec 2013 16:11:39 -0500
Message-ID: <20131218161139.2bb1538f@gandalf.local.home>
References: <20131214101042.5626c785@gandalf.local.home>
	<52AEA3F6.2090508@cn.fujitsu.com>
	<20131218155549.25c09718@gandalf.local.home>
	<20131218210817.GC15863@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	Clark Williams <williams@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.225]:34514 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751367Ab3LRVLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:11:41 -0500
In-Reply-To: <20131218210817.GC15863@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 22:08:17 +0100
Florian Westphal <fw@strlen.de> wrote:

> Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Mon, 16 Dec 2013 14:55:50 +0800
> > Gao feng <gaofeng@cn.fujitsu.com> wrote:
> > > On 12/14/2013 11:10 PM, Steven Rostedt wrote:
> [..]
> > > > BUG: unable to handle kernel paging request at ffffffffa06189f0 
> > > > IP: [<ffffffff814b7904>] nf_log_proc_dostring+0x94/0x1a0 
> [..]
> 
> > > > And after the module-load test, it crashes when reading those files.
> > > > 
> > > 
> > > Oops, I forgot to unset the nf_loggers of net namespace when unload module nfnetlink_log.
> > > I will send a patch, please have a try.
> > 
> > Hi Gao,
> > 
> > I haven't seen a patch. Was one sent?
> 
> Yes, submitted to netfilter-devel, see http://patchwork.ozlabs.org/patch/301485/

Thanks, someone else pointed it to me on netdev list. I wasn't on the
Cc, so I missed it.

-- Steve
