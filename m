From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
	paravirt ops callsites to make them patchable
Date: Mon, 19 Mar 2007 11:41:37 -0700
Message-ID: <20070319184137.GB10574@sequoia.sous-sol.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zach@vmware.com, jeremy@goop.org, xen-devel@lists.xensource.com,
	anthony@codemonkey.ws, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	Andi Kleen <ak@muc.de>, mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <m1648xxf93.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Eric W. Biederman (ebiederm@xmission.com) wrote:
> Is it truly critical to inline any of these instructions?

I don't have any current measurements.  But we'd been aiming
at getting irq_{en,dis}able to a simple memory write to pda.
But simplicity, maintenance, etc. win over trimming a couple
cycles, so still worth real look.

thanks,
-chris
