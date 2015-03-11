From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 10:52:10 -0400
Message-ID: <20150311105210.1855c95e@gandalf.local.home>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
	<20150311081909.552e2052@grimm.local.home>
	<55003666.3020100@oracle.com>
	<20150311084034.04ce6801@grimm.local.home>
	<55004595.7020304@oracle.com>
	<20150311102636.6b4110a8@gandalf.local.home>
	<55005491.5080809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <55005491.5080809@oracle.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Mar 2015 10:43:29 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> On 03/11/2015 10:26 AM, Steven Rostedt wrote:
> >> There's no real hurry to kill kmemcheck right now, but we do want to stop
> >> > supporting that in favour of KASan.
> > Understood, but the kernel is suppose to support older compilers.
> > Perhaps we can keep kmemcheck for now and say it's obsoleted if you
> > have a newer compiler. Because it will be a while before I upgrade my
> > compilers. I don't upgrade unless I have a good reason to do so. Not
> > sure KASan fulfills that requirement.
> 
> It's not that there's a performance overhead with kmemcheck, it's the
> maintenance effort that we want to get rid of.

I totally understand this.

> 
> The kernel should keep supporting old kernels, and after this kmemcheck
> removal your kernel will still keep working - this is more of a removal
> of a mostly unused feature that had hooks everywhere in the kernel.
> 
> Did you actually find anything recently with kmemcheck?

I have to look. I think I did find something last year. I run it every
other month or so, so it's not something I do every day.

> How do you deal
> with the 1 CPU limit and the massive performance hit?

I just deal with it :-)

I have test boxes that I kick off and just let run. It's not that bad
if you are not using the box for actual work.

> 
> Could you try KASan for your use case and see if it potentially uncovers
> anything new?

The problem is, I don't have a setup to build with the latest compiler.

I could build with my host compiler (that happens to be 4.9.2), but it
would take a while to build, and is not part of my work flow.

4.9.2 is very new, I think it's a bit premature to declare that the
only way to test memory allocations is with the latest and greatest
kernel.

But if kmemcheck really doesn't work anymore, than perhaps we should
get rid of it.

-- Steve
