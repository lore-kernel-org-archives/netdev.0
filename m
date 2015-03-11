From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 10:43:29 -0400
Message-ID: <55005491.5080809@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>	<20150311081909.552e2052@grimm.local.home>	<55003666.3020100@oracle.com>	<20150311084034.04ce6801@grimm.local.home>	<55004595.7020304@oracle.com> <20150311102636.6b4110a8@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150311102636.6b4110a8@gandalf.local.home>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2015 10:26 AM, Steven Rostedt wrote:
>> There's no real hurry to kill kmemcheck right now, but we do want to stop
>> > supporting that in favour of KASan.
> Understood, but the kernel is suppose to support older compilers.
> Perhaps we can keep kmemcheck for now and say it's obsoleted if you
> have a newer compiler. Because it will be a while before I upgrade my
> compilers. I don't upgrade unless I have a good reason to do so. Not
> sure KASan fulfills that requirement.

It's not that there's a performance overhead with kmemcheck, it's the
maintenance effort that we want to get rid of.

The kernel should keep supporting old kernels, and after this kmemcheck
removal your kernel will still keep working - this is more of a removal
of a mostly unused feature that had hooks everywhere in the kernel.

Did you actually find anything recently with kmemcheck? How do you deal
with the 1 CPU limit and the massive performance hit?

Could you try KASan for your use case and see if it potentially uncovers
anything new?


Thanks,
Sasha
