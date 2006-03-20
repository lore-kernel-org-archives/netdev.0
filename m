From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 10:09:42 -0500
Message-ID: <20060320150941.GD16108@kvack.org>
References: <20060320090629.GA11352@mellanox.co.il>
	<20060320.015500.72136710.davem@davemloft.net>
	<20060320102234.GV29929@mellanox.co.il>
	<20060320.023704.70907203.davem@davemloft.net>
	<20060320112753.GX29929@mellanox.co.il>
	<1142855223.3114.30.camel@laptopd505.fenrus.org>
	<20060320114933.GA3058@xi.wantstofly.org>
	<20060320120407.GY29929@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <openib-general-bounces@openib.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Content-Disposition: inline
In-Reply-To: <20060320120407.GY29929@mellanox.co.il>
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

On Mon, Mar 20, 2006 at 02:04:07PM +0200, Michael S. Tsirkin wrote:
> does not stretch ACKs anymore. RFC 2581 does mention that it might be OK to
> stretch ACKs "after careful consideration", and we are seeing that it helps
> IP over InfiniBand, so recent Linux kernels perform worse in that respect.
> 
> And since there does not seem to be a way to figure it out automagically when
> doing this is a good idea, I proposed adding some kind of knob that will let the
> user apply the consideration for us.

Wouldn't it make sense to strech the ACK when the previous ACK is still in 
the TX queue of the device?  I know that sort of behaviour was always an 
issue on modem links where you don't want to send out redundant ACKs.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
