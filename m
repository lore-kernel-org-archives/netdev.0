From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Sun, 18 Mar 2007 00:59:03 -0700
Message-ID: <45FCF147.30409@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>	<45FB005D.9060809@goop.org>	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zach@vmware.com, xen-devel@lists.xensource.com, ak@muc.de,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, anthony@codemonkey.ws,
	mingo@elte.hu, torvalds@linux-foundation.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <20070318.003309.71088169.davem@davemloft.net>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

David Miller wrote:
> The idea is _NOT_ that you go look for references to the paravirt_ops
> members structure, that would be stupid and you wouldn't be able to
> use the most efficient addressing mode on a given cpu, you'd be
> patching up indirect calls and crap like that.  Just say no...
>
> Instead you get rid of paravirt ops completely, and you call functions
> whose symbol name will not resolve in the initial kernel link.
>   

Yeah, I came to that conclusion after thinking about it for a while. 
Thanks for the pointer to the sparc stuff; it looks very interesting.

    J
