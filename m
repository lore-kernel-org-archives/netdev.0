From: Peter Foley <pefoley2@pefoley.com>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross builds
Date: Tue, 21 Oct 2014 18:04:51 -0400
Message-ID: <CAOFdcFNYHgupvMChb4NedMsUMAOmE8k0D_F5eRjL-8H8ft=eRw@mail.gmail.com>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
 <20141021110724.GA16479@netboy> <20141021.123544.9516812519754063.davem@davemloft.net>
 <544690CB.4030307@gmail.com> <20141021182757.GA3960@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Daney <ddaney.cavm@gmail.com>,
	David Miller <davem@davemloft.net>, markos.chandras@imgtec.com,
	linux-mips@linux-mips.org, corbet@lwn.net, netdev@vger.kernel.org,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20141021182757.GA3960@localhost.localdomain>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 21, 2014 at 2:27 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Oct 21, 2014 at 09:58:51AM -0700, David Daney wrote:
>> What I don't understand is why we are using hostprogs in this
>> Makefile.  Isn't this a program that would run on the target, not
>> the build host?
>
> Yes.
>
> Peter, could you please fix it?


The intention of these changes was to generate more compiliation
coverage for code in Documentation/
The underlying issue is that this doesn't work for cross-compiling
because kbuild doesn't have cross-compile support for userspace code.
I submitted a patch to disable building Documentation when
cross-compiling, as the consensus in the thread that resulted in that
patch (https://lkml.org/lkml/2014/10/8/510) was that implementing
targetprogs in kbuild was not currently worth it.
I can try to take a crack at adding targetprogs support, but I'm
rather busy right now, so it may take a little while.

Thanks,

Peter
