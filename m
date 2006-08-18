From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6.19 PATCH 1/7] ehea: interface to network stack
Date: Fri, 18 Aug 2006 15:56:17 +0200
Message-ID: <1155909377.4494.192.camel@laptopd505.fenrus.org>
References: <200608181329.02042.ossthema@de.ibm.com>
	 <20060818134728.GB5201@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:16291 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030399AbWHRN4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 09:56:41 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060818134728.GB5201@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-18 at 17:47 +0400, Alexey Dobriyan wrote:
> On Fri, Aug 18, 2006 at 01:29:01PM +0200, Jan-Bernd Themann wrote:
> 
> Was there noticeable performance difference when explicit prefetching is
> removed? At some (invisible) point CPUs will become smarter about prefetching
> than programmers and this code will be slower than possible.

Hi,

what you say is true in general, however the packet response part of the
kernel is special; the cpu just cannot know where your card just dma'd
the packet to (and thus cleared it from any caches anywhere in the
system) so it's going to be pretty much a 100% cachemiss always...

Greetings,
   Arjan van de Ven

