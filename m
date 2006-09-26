From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2.6.19-rc1] ehea firmware interface based on Anton
	Blanchard's new hvcall interface
Date: Tue, 26 Sep 2006 12:53:51 +1000
Message-ID: <1159239231.5462.8.camel@localhost.localdomain>
References: <200609251550.01514.ossthema@de.ibm.com>
	 <45186F25.9000700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, pmac@au1.ibm.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:5863 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1750732AbWIZCzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 22:55:44 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45186F25.9000700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-25 at 20:07 -0400, Jeff Garzik wrote:
> patch does not apply.
> 
> also, it would seem like varargs would be appropriate here.

Not really... these are hypervisor calls, their calling convention is
not varargs, thus we would need some conversion layer if using them,
with possible performance loss (it's also hard to do right as we are
passing args by registers, not stack).

Ben.


