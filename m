From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 22:08:00 -0800
Message-ID: <20070320220800.76baff30.akpm@linux-foundation.org>
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
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>,
   anthony@codemonkey.ws, mingo@elte.hu,
   Linus Torvalds <torvalds@linux-foundation.org>,
   David Miller <davem@davemloft.net>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070320202352.GF4286@bingen.suse.de>
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

On Tue, 20 Mar 2007 21:23:52 +0100 Andi Kleen <ak@suse.de> wrote:

> Well it causes additional problems. We had some cases where it was really
> hard to distingush garbage and the true call chain.

yes, for some reason the naive backtraces seem to have got messier and mess=
ier over
the years and some of them are really quite hard to piece together nowadays.

An accurate backtrace would have some value, if we can get it bullet-proof.

The fault-injection driver wants it too.  And lockdep, I guess.
