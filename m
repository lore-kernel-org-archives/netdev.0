From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 19 Dec 2004 14:31:15 -0500
Message-ID: <1103484675.1050.158.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041217214432.07b7b21e.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Sat, 2004-12-18 at 00:44, David S. Miller wrote:

> Perhaps one way to fix this is to add a pointer to a spinlock to
> the netdev struct, and have hold that the upper level grab that
> when NETIF_F_LLTX when doing queue state checks.  Actually, that
> could end up being racy too.

How about releasing the qlock only when the LLTX transmit lock is
grabbed? That should bring it to par with what it was originally.

cheers,
jamal
