From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Documentation: ptp: Fix build failure on MIPS cross
 builds
Date: Wed, 22 Oct 2014 10:03:02 +0200
Message-ID: <20141022080302.GA4037@localhost.localdomain>
References: <1413794538-28465-1-git-send-email-markos.chandras@imgtec.com>
 <20141021110724.GA16479@netboy>
 <20141021.123544.9516812519754063.davem@davemloft.net>
 <544690CB.4030307@gmail.com>
 <20141021182757.GA3960@localhost.localdomain>
 <CAOFdcFNYHgupvMChb4NedMsUMAOmE8k0D_F5eRjL-8H8ft=eRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney.cavm@gmail.com>,
        David Miller <davem@davemloft.net>, markos.chandras@imgtec.com,
        linux-mips@linux-mips.org, corbet@lwn.net, netdev@vger.kernel.org,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Peter Foley <pefoley2@pefoley.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <CAOFdcFNYHgupvMChb4NedMsUMAOmE8k0D_F5eRjL-8H8ft=eRw@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Tue, Oct 21, 2014 at 06:04:51PM -0400, Peter Foley wrote:
> The intention of these changes was to generate more compiliation
> coverage for code in Documentation/

Sounds good.

> The underlying issue is that this doesn't work for cross-compiling
> because kbuild doesn't have cross-compile support for userspace code.

Well, my testptp does cross compile just fine. All it needs is the glibc
library bundled with the tool chain and the kernel headers.

> I submitted a patch to disable building Documentation when
> cross-compiling, as the consensus in the thread that resulted in that
> patch (https://lkml.org/lkml/2014/10/8/510) was that implementing
> targetprogs in kbuild was not currently worth it.

So this patch did not make it in, right?

Otherwise people wouldn't be disabling cross compilation ad hoc, like
in the patch that started this thread.

> I can try to take a crack at adding targetprogs support, but I'm
> rather busy right now, so it may take a little while.

No rush, please do.

In the mean time, I would like to restore the testptp.mk that *does*
cross compile, so that people may use the test program if they
want. In fact I use this all the time, and so I am a bit annoyed that
something working was deleted and replaced with something broken.

Thanks,
Richard
