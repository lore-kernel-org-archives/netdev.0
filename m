From: Roland Dreier <roland@topspin.com>
Subject: Re: LLTX and netif_stop_queue
Date: Wed, 22 Dec 2004 20:38:34 -0800
Message-ID: <52pt11bpdh.fsf@topspin.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Eric Lemoine <eric.lemoine@gmail.com>,
	hadi@cyberus.ca, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041222202919.057b8331.davem@davemloft.net> (David S.
	Miller's message of "Wed, 22 Dec 2004 20:29:19 -0800")
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

    David> That sounds about right.  Nice idea.  It solves the race,
    David> and retains the error state check.

Great, I've made a similar change to the IP-over-IB driver.

Thanks,
  Roland
