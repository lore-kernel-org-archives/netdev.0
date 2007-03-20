From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 10:27:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org>
References: <20070319.120854.30182994.davem@davemloft.net>
	<20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
	<200703201428.50564.ak@suse.de>
	<m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
	<20070320174159.GA4286@bingen.suse.de>
	<Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
	<20070320180359.GB4286@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org, mingo@elte.hu,
   linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>,
   anthony@codemonkey.ws, akpm@linux-foundation.org,
   David Miller <davem@davemloft.net>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070320180359.GB4286@bingen.suse.de>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Tue, 20 Mar 2007, Andi Kleen wrote:
> =

> The code never did that. In fact many of the problems we had initially
> especially came out of that -- the fallback code that would handle
> this case wasn't fully correct.

I don't keep my emails any more, but you *never* fixed the problems in =

arch/*/kernel/traps.c.

Yes, the kernel/unwind.c issues generally got fixed. The infinite loops in =

the *callers* never did.

> Also frankly often your analysis about what went wrong was just
> incorrect.

Still in denial, I see.

Do you still claim that "the fallback position always did the right =

thing"? Despite the fact that the unwinder had sometimes *corrupted* the =

incoming information so much that the fallback position was the one that =

oopsed? And no, you didn't fix that.

And no, IT DID NOT use probe_kernel_address like you still claim.

Anyway, you work for Suse, I don't care what you do to the Suse kernel. =

Maybe it will get stable some day. Somehow, I doubt it. =


			Linus
