From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6.19 PATCH 4/7] ehea: ethtool interface
Date: Fri, 18 Aug 2006 10:45:47 -0700
Message-ID: <20060818104547.5ad1352f@localhost.localdomain>
References: <200608181333.23031.ossthema@de.ibm.com>
	<20060818140506.GC5201@martell.zuzino.mipt.ru>
	<44E5DFA6.7040707@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25475 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751442AbWHRRqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 13:46:00 -0400
To: Thomas Klein <osstklei@de.ibm.com>
In-Reply-To: <44E5DFA6.7040707@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Aug 2006 17:41:26 +0200
Thomas Klein <osstklei@de.ibm.com> wrote:

> Hi Alexey,
> 
> first of all thanks a lot for the extensive review.
> 
> 
> Alexey Dobriyan wrote:
> >> +	u64 hret = H_HARDWARE;
> > 
> > Useless assignment here and everywhere.
> > 
> 
> Initializing returncodes to errorstate is a cheap way to prevent
> accidentally returning (uninitalized) success returncodes which
> can lead to catastrophic misbehaviour.

That is old thinking. Current compilers do live/dead analysis
and tell you about this at compile time which is better than relying
on default behavior at runtime.
