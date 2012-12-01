From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v1 1/2] bridge: export port_no and
 port_id via IFA_INFO_DATA
Date: Sat, 01 Dec 2012 11:53:43 +0800
Message-ID: <1354334023.9680.4.camel@cr0>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
	<20121130075254.14aac5ce@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121130075254.14aac5ce@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-30 at 07:52 -0800, Stephen Hemminger wrote:
> I don't think these are necessary. The device is already available and
> the relationship
> can be determined from other messages. This is what RSTP daemon does.
> 

Rethinking about it, I think we can just put port->dev->ifindex instead
of port->port_no in the netlink message, so patch 1/2 is not needed at
more.

Thanks!
