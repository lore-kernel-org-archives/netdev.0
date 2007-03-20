From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Xen-devel] Re: [patch 13/26] Xen-paravirt_ops: Consistently
	wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 16:51:19 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703201644490.6730@woody.linux-foundation.org>
References: <200703201428.50564.ak@suse.de>
	<m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
	<20070320174159.GA4286@bingen.suse.de>
	<Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
	<20070320180359.GB4286@bingen.suse.de>
	<Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org>
	<20070320192118.GD4286@bingen.suse.de>
	<Pine.LNX.4.64.0703201145570.6730@woody.linux-foundation.org>
	<20070320202352.GF4286@bingen.suse.de>
	<20070320213918.116862be@lxorguk.ukuu.org.uk>
	<20070320214945.GG4286@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, David Miller <davem@davemloft.net>,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>,
   anthony@codemonkey.ws, mingo@elte.hu, akpm@linux-foundation.org,
   Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070320214945.GG4286@bingen.suse.de>
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

> Linus is worried about the unwinder crashing -- that wouldn't help with t=
hat.

And to make it clear: this is not a theoretical worry. It happened many =

times over the months the unwinder was in. =


It was supposed to help debugging, but it made bugs that *would* have been =

nicely debuggable without it into nightmares. So the only reason for it =

existing in the first place was actually the thing that made it not work.

		Linus
