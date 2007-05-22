From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: Re: [PATCH 3/4] [Net] Support Xen accelerated
	network plugin modules
Date: Tue, 22 May 2007 08:28:41 +0100
Message-ID: <1179818921.4145.29.camel@moonstone.uk.level5networks.com>
References: <1179494208.14376.10.camel@moonstone.uk.level5networks.com>
	<20070521105258.7988fd6e@freepuppy>
	<1179818108.4145.18.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: muli@il.ibm.com, netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	herbert@gondor.apana.org.au
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1179818108.4145.18.camel@moonstone.uk.level5networks.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-22 at 08:15 +0100, Kieran Mansley wrote:
> RCU on its own wouldn't
> prevent the accelerated plugin being unloaded while netfront was using
> one of the hooks. 

Hmm, actually I think it could be used to do that.  I'll take a look.

Kieran
