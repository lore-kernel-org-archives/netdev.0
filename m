From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 18:16:51 +0200
Message-ID: <200608181816.52079.arnd.bergmann@de.ibm.com>
References: <OFC184057C.C58732A2-ONC12571CE.004E5EF6-C12571CE.004ED1D4@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Q Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>, tklein@linux.ibm.com,
	abergman@de.ibm.com, Arjan van de Ven <arjan@infradead.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc-dev@ozlabs.org
In-Reply-To: <OFC184057C.C58732A2-ONC12571CE.004E5EF6-C12571CE.004ED1D4@de.ibm.com>
Content-Disposition: inline
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

On Friday 18 August 2006 16:24, Christoph Raisch wrote:
> And as always in performance tuning... one size fits all unfortunately is
> not the correct answer.

Ah, good. What is the maximum sensible value that you came up with?

> Therefore we'll leave that open to the user as most other new ethernet
> driver did as well.

Sure. The interesting question is whether you want to allow users
to set it to a value that is no longer sensible to do with
__get_free_pages() and requires vmalloc().

	Arnd <><
