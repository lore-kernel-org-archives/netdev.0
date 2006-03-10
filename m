From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Thu, 09 Mar 2006 23:18:06 -0800 (PST)
Message-ID: <20060309.231806.10212645.davem@davemloft.net>
References: <20060308125311.GE17618@mellanox.co.il>
	<20060309.154819.104282952.davem@davemloft.net>
	<20060310001031.GA19040@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: mst@mellanox.co.il
In-Reply-To: <20060310001031.GA19040@mellanox.co.il>
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

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Fri, 10 Mar 2006 02:10:31 +0200

> But with the change we are discussing, could an ack now be sent even
> sooner than we have at least two full sized segments?  Or does
> __tcp_ack_snd_check delay until we have at least two full sized
> segments? David, could you explain please?

__tcp_ack_snd_check() delays until we have at least two full
sized segments.
