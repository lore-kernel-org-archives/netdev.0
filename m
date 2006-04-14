From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 14:02:25 -0700 (PDT)
Message-ID: <20060414.140225.113553109.davem@davemloft.net>
References: <Pine.LNX.4.64.0604051734230.9255@lindenhurst-2.jf.intel.com>
	<44350056.80501@kernelpanic.ru>
	<444005DA.4090606@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bb@kernelpanic.ru, herbert@gondor.apana.org.au,
	kernel@linuxace.com, nipsy@bitgnome.net, jrlundgren@gmail.com,
	cat@zip.com.au, djani22@dynamicweb.hu, yoseph.basri@gmail.com,
	mykleb@no.ibm.com, olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50584
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965165AbWDNVK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 17:10:56 -0400
To: jesse.brandeburg@intel.com
In-Reply-To: <444005DA.4090606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Fri, 14 Apr 2006 13:28:10 -0700

> We also have some new data from the last couple of days.  First, I think 
> that this problem is likely not just E1000's fault.  We have multiple 
> reports both in bugzilla.kernel.org and from a distro that show this 
> problem has occurred on (at least) tg3 driven adapters as well as e1000.

That's interesting since tg3 does not enable TSO by default for any
chip until very recent versions of the tg3 driver.  And even with
those recent tg3 drivers which will enable TSO by default, it is only
done for a very specific selection of chip revisions.

Where are these reports that precisely implicate tg3?

Note that there were legitimate TSO retransmit bugs in the 2.6.14
timeframe that triggered those messages and did get fixed.  And yes
some of those reports were with tg3.
