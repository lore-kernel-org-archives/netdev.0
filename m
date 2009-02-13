From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Fri, 13 Feb 2009 15:48:29 +0300
Message-ID: <20090213124829.GA23879@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090212191824.GB17896@ioremap.net> <alpine.LSU.2.00.0902122112280.670@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:53375 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752283AbZBMMsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2009 07:48:33 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902122112280.670@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2009 at 09:19:18PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >> Make use of xtables_strtoui to do bounds checking on the TTL value.
> >
> >Hmm...
> >$ grep xtables_strtoui -r /tmp/iptables-1.4.2
> >$
> 
> It is going to be in 1.4.3, after whose release is the earliest point
> ipt_osf (or xt_osf :) will probably find its way into the mainlines.
> In 1.4.2, it is still called strtonum.

But it can be built with older (and already running) installation, with
xtables_strtoui() this will not be allowed.

-- 
	Evgeniy Polyakov
