From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 06 Mar 2006 14:40:34 -0800 (PST)
Message-ID: <20060306.144034.53871111.davem@davemloft.net>
References: <20060306223438.GA18277@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: mst@mellanox.co.il
In-Reply-To: <20060306223438.GA18277@mellanox.co.il>
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
Date: Tue, 7 Mar 2006 00:34:38 +0200

> So I'm trying to get a handle on it: could a solution be to simply
> look at the frame size, and call tcp_send_delayed_ack from
> if the frame size is no larger than 1/8?
> 
> Does this make sense?

The comment you mention is very old, and no longer applies.

Get full packet traces from the kernel TSO code in the 2.6.x
kernel, analyze is, and post here what you think is occuring
that is causing the performance problems.

One thing to note is that the newer TSO code really needs to
have large socket buffers, so you can experiment with that.
