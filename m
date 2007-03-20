From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Re: [patch 13/26] Xen-paravirt_ops: Consistently
	wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 21:39:18 +0000
Message-ID: <20070320213918.116862be@lxorguk.ukuu.org.uk>
References: <20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
	<200703201428.50564.ak@suse.de>
	<m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
	<20070320174159.GA4286@bingen.suse.de>
	<Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
	<20070320180359.GB4286@bingen.suse.de>
	<Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org>
	<20070320192118.GD4286@bingen.suse.de>
	<Pine.LNX.4.64.0703201145570.6730@woody.linux-foundation.org>
	<20070320202352.GF4286@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, xen-devel@lists.xensource.com, Andi,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kleen <ak@suse.de>, jbeulich@novell.com,
	virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	anthony@codemonkey.ws, mingo@elte.hu,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070320202352.GF4286@bingen.suse.de>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

> > Because that's really the issue: do you want a "pretty" backtrace, or do 
> > you want one that is rock solid but has some crud in it.
> 
> I just want an as exact backtrace as possible. I also think
> that we can make the unwinder robust enough.

Any reason you can't put the exact back trace in "[xxx]" and the ones we
see on the stack which dont look like call trace as ?xxx? It makes the
code a bit trickier but we depend on the quality of traces

Alan
