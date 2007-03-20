From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 12:12:29 -0400
Message-ID: <460007ED.5010805@redhat.com>
References: <20070319.120854.30182994.davem@davemloft.net>	<200703192159.42396.ak@suse.de>	<Pine.LNX.4.64.0703192015020.6730@woody.linux-foundation.org>	<20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org, mingo@elte.hu,
   jbeulich@novell.com, linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, anthony@codemonkey.ws,
   akpm@linux-foundation.org, virtualization@lists.linux-foundation.org,
   torvalds@linux-foundation.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
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

Eric W. Biederman wrote:
 =

> I'm conflicted about the dwarf unwinder.  I was off doing other things
> at the time so I missed the pain, but I do have a distinct recollection of
> the back traces on x86_64 being distinctly worse the on i386.  Lately
> I haven't seen that so it may be I was misinterpreting what I was
> seeing, and the compiler optimizations were what gave me such weird
> back traces.  =

> =


Well, if you compile x86_64 with frame pointers it helps a bit because
the compiler doesn't tail merge function calls. But the stack backtrace
ignores the frame pointers even if they're present, unlike i386 which
will use them.
