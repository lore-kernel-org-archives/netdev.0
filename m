From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ehea: Optional TX/RX path optimized for SMP
Date: Sat, 03 Mar 2007 09:28:28 +0100
Message-ID: <1172910508.8184.53.camel@localhost.localdomain>
References: <200702231730.58579.ossthema@de.ibm.com>
	 <p73mz2vauvz.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43435 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbXCCI2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 03:28:47 -0500
In-Reply-To: <p73mz2vauvz.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-03-03 at 04:06 +0100, Andi Kleen wrote:
> Jan-Bernd Themann <ossthema@de.ibm.com> writes:
> > 
> > Are there any concerns about this approach?
> 
> Yes. You should fix the NAPI code instead of trying to work
> around it.

NAPI is being fixed but the fix will take time to get in. In the
meantime, the solution to get something working is the workaround.

Ben.


