From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/4][RFC] lro: Generic Large Receive Offload for TCP
	traffic
Date: Mon, 30 Jul 2007 12:17:58 -0400
Message-ID: <46AE0F36.8030605@garzik.org>
References: <200707301724.33865.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>, Andrew Gallatin <gallatin@myri.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <200707301724.33865.ossthema@de.ibm.com>
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

Seems pretty good to me, save for one minor detail:  patches #1/#2 
should be combined together for greater git-bisect happiness.  Ditto for 
patches #3/#4.  Largely harmless in this case, but keeps the git history 
pollution to a minimum.

Caveat reviewer:  I'm not an expert of net/ipv4/* code, so I reviewed 
largely from the driver API perspective.

David, thoughts on merging?  I'm not We could stick this into your tree 
or mine.  Whether yours or mine, I would like to keep the driver and 
net-core patches together in the same git tree.

	Jeff
