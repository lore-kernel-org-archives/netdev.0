From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] HTB initialize upper bound properly
Date: Fri, 14 Jul 2006 16:32:45 -0700 (PDT)
Message-ID: <20060714.163245.106771234.davem@davemloft.net>
References: <20060714120341.0c7f4466@dxpl.pdx.osdl.net>
	<1152914786.16981.25.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44232
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1945915AbWGNXcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 19:32:39 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152914786.16981.25.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jamal Hadi Salim <hadi@cyberus.ca>
Date: Fri, 14 Jul 2006 18:06:26 -0400

> On Fri, 2006-14-07 at 12:03 -0700, Stephen Hemminger wrote:
> > The upper bound for HTB time diff needs to be scaled to PSCHED
> > units rather than just assuming usecs.  The field mbuffer is used
> > in TDIFF_SAFE(), as an upper bound.  Untested...
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> Looks good to me.

Me too, thanks Stephen.
