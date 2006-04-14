From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 15:32:55 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141527420.2116@jbrandeb-desk.amr.corp.intel.com>
References: <Pine.LNX.4.64.0604051734230.9255@lindenhurst-2.jf.intel.com>
 <44350056.80501@kernelpanic.ru> <444005DA.4090606@intel.com>
 <20060414.140225.113553109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, bb@kernelpanic.ru,
	herbert@gondor.apana.org.au, kernel@linuxace.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:44691 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751265AbWDNWfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:35:22 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.140225.113553109.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 14 Apr 2006, David S. Miller wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Fri, 14 Apr 2006 13:28:10 -0700
> 
> > We also have some new data from the last couple of days.  First, I think 
> > that this problem is likely not just E1000's fault.  We have multiple 
> > reports both in bugzilla.kernel.org and from a distro that show this 
> > problem has occurred on (at least) tg3 driven adapters as well as e1000.
> 
> That's interesting since tg3 does not enable TSO by default for any
> chip until very recent versions of the tg3 driver.  And even with
> those recent tg3 drivers which will enable TSO by default, it is only
> done for a very specific selection of chip revisions.
> 
> Where are these reports that precisely implicate tg3?

well there was one of them here, but the tg3 bit may actually be due to 
the 2.6.14 problems.

http://bugzilla.kernel.org/show_bug.cgi?id=6279

the other one is buried at a distro's bugzilla, so I can't post it.

> Note that there were legitimate TSO retransmit bugs in the 2.6.14
> timeframe that triggered those messages and did get fixed.  And yes
> some of those reports were with tg3.

I've removed the call to pskb_expand_head in e1000 (yes i know its not 
quite right, but it shouldn't be fatal either) and the bug still occurs.

so its something else.  I'm not giving up on this, I just want to post the 
state of the investigation.

Jesse
