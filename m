From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/8] ibm_newemac: Fix possible lockup on close
Date: Wed, 21 Nov 2007 16:41:23 +0100
Message-ID: <20071121154123.GB23589@lst.de>
References: <1195625198.76200.922309668615.qpush@grosgo>
	<20071121060729.71A1FDDE01@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20071121060729.71A1FDDE01@ozlabs.org>
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

On Wed, Nov 21, 2007 at 05:06:39PM +1100, Benjamin Herrenschmidt wrote:
> It's a bad idea to call flush_scheduled_work from within a
> netdev->stop because the linkwatch will occasionally take the
> rtnl lock from a workqueue context, and thus that can deadlock.
> 
> This reworks things a bit in that area to avoid the problem.

So from the name of the driver you want to keep the previous emac
driver around.  Is there a good reason for that?
