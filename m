From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: 19 Jan 2005 23:01:47 -0500
Message-ID: <1106193707.1048.4.camel@jzny.localdomain>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, eric.lemoine@gmail.com, ak@suse.de,
	openib-general@openib.org, kaber@trash.net,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050119164640.6c67bdfa.davem@davemloft.net>
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


One thing i didnt quiet follow Dave in some of the drivers, example in
the e1000:

-----
/* Called with dev->xmit_lock held and interrupts disabled.  */
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
---

Who calls that with dev->xmit_lock held and interrupts disabled?
Shouldnt the spin_unlock(&netdev->xmit_lock); be right at the top of
that routine now?

cheers,
jamal
