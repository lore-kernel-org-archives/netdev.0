From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 19 Dec 2004 18:06:32 -0500
Message-ID: <1103497592.1046.235.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<52fz21ncgh.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52fz21ncgh.fsf@topspin.com>
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

On Sun, 2004-12-19 at 17:35, Roland Dreier wrote:
>     jamal> How about releasing the qlock only when the LLTX transmit
>     jamal> lock is grabbed? That should bring it to par with what it
>     jamal> was originally.
> 
> This seems a little risky.  I can't point to a specific deadlock but
> it doesn't seem right on general principles to unlock in a different
> order than you nested the locks when acquiring them -- if I understand
> correctly, you're suggesting lock(queue_lock), lock(tx_lock),
> unlock(queue_lock), unlock(tx_lock).

There is no deadlock. Thats exactly how things work. Try the patches i
posted. 

cheers,
jamal
