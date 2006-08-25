From: David Miller <davem@davemloft.net>
Subject: Re: IPSec kernel oops on ppc64
Date: Fri, 25 Aug 2006 16:19:42 -0700 (PDT)
Message-ID: <20060825.161942.27783441.davem@davemloft.net>
References: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
	<Pine.LNX.4.64.0608251915140.27896@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, netdev@vger.kernel.org, gcwilson@us.ibm.com,
	jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55479
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422883AbWHYXTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:19:37 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0608251915140.27896@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Fri, 25 Aug 2006 19:15:57 -0400 (EDT)

> On Fri, 25 Aug 2006, Joy Latten wrote:
> 
> > I installed 2.6.17 + patch-2.6.18-rc4 + 2.6.18-rc4-mm2
> > onto two pSeries power 5 (ppc64 lpars) machines. I configured
> > IPSec using the configuration listed below. 
> 
> Confirming that this does not crash on i686 or x86_64.

Probably best to start with retesting with 2.6.18-rc4, and
if that crashes too it is time to think seriously about
a miscompile on ppc64.
