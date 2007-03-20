From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Mon, 19 Mar 2007 20:18:14 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703192015020.6730@woody.linux-foundation.org>
References: <20070318193030.GB71548@muc.de> <200703191157.29780.ak@suse.de>
	<20070319.120854.30182994.davem@davemloft.net>
	<200703192159.42396.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org, mingo@elte.hu,
   linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, anthony@codemonkey.ws,
   akpm@linux-foundation.org, David Miller <davem@davemloft.net>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200703192159.42396.ak@suse.de>
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



On Mon, 19 Mar 2007, Andi Kleen wrote:
> =

> Initially we had some bugs that accounted for near all failures, but they =

> were all fixed in the latest version.

No. The real bugs were that the people involved wouldn't even accept that =

unwinding information was inevitably buggy and/or incomplete.

That much more fundamental bug never got fixed, as far as I know. =


I'm not going to merge anything that depends on unwind tables as things =

stand. The pain just isn't worth it.

> > Please don't subject us to another couple months of hair-pulling only
> > to have Linus yank the thing out again, there are certainly more
> > useful things to spend time on :-)

Good call. Dwarf2 unwinding simply isn't worth doing. But I won't yank it =

out, I simply won't merge it. It was more than just totally buggy code, it =

was an inability of the people to understand that even bugfree code =

isn't enough - you have to be able to also handle buggy data.

		Linus
