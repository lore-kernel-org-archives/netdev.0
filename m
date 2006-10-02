From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 0/6]: powerpc/cell spidernet ethernet patches
Date: Mon, 2 Oct 2006 11:27:49 -0500
Message-ID: <20061002162749.GB4546@austin.ibm.com>
References: <20060929230552.GG6433@austin.ibm.com>
	<200609301240.03464.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200609301240.03464.arnd@arndb.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 30, 2006 at 12:40:00PM +0200, Arnd Bergmann wrote:
> Am Saturday 30 September 2006 01:05 schrieb Linas Vepstas:
> >
> > Although these patches improve things, I am not
> > satisfied with how this driver behaves, and so
> > plan to do additional work next week.
> >
> 
> I'm not sure if I have missed a patch in here, but I
> don't see anything reintroducing the 'netif_stop_queue'
> that is missing from the transmit path.
> 
> Do you have a extra patch for that?

Unfinished.  There are several ways in which the current 
spider-net driver doesn't do things the way Greg KH's, etal 
book on device drivers recommends. I was planning on combing 
through these this week.

--linas
