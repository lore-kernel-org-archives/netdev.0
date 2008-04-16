From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Wed, 16 Apr 2008 20:05:40 +0400
Message-ID: <20080416160540.GB442@polina.dev.rtsoft.ru>
References: <200804161640.42693.laurentp@cse-semaphore.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <200804161640.42693.laurentp@cse-semaphore.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2008 at 04:40:42PM +0200, Laurent Pinchart wrote:
> This patch converts the MII bitband driver to use GPIO lib for GPIO access.
> The driver can now handle MDC and MDIO on different GPIO banks.
> 
> The patch depends on Anton Vorontsov GPIO lib support scheduled for 2.6.26.
> It is by no means complete, I just would like to get some feedback on the
> approach. I'll resubmit it when the CPM2 GPIO support patches will be
> available in the powerpc git tree.

Cool! By the way, maybe it is worth splitting it into completely separate
driver, e.g. net/mdio_gpio.c? Plus, keep in mind that somebody will
eventually want this cool stuff with platform_device bindings in addition. :-)

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
