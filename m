From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v2] bridge: export multicast database
 via netlink
Date: Wed, 05 Dec 2012 10:08:59 +0800
Message-ID: <1354673339.28951.3.camel@cr0>
References: <1354539824-7898-1-git-send-email-amwang@redhat.com>
	<20121204085320.3e08986a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121204085320.3e08986a@nehalam.linuxnetplumber.net>
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

On Tue, 2012-12-04 at 08:53 -0800, Stephen Hemminger wrote:
> On Mon,  3 Dec 2012 21:03:43 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > V2: drop patch 1/2, export ifindex directly
> >     Redesign netlink attributes
> >     Improve netlink seq check
> >     Handle IPv6 addr as well
> > 
> > TODO: remove debugging printk's
> > 
> > This patch exports bridge multicast database via netlink
> > message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
> > We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Stephen Hemminger <shemminger@vyatta.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> >     
> 
> Minor nit reported by checkpatch was the messages should be using the api
> which provides the most info in the log to identify.
> 
> WARNING: Prefer netdev_info(netdev, ... then dev_info(dev, ... then pr_info(...  to printk(KERN_INFO ...
> #190: FILE: net/bridge/br_mdb.c:28:
> +		printk(KERN_INFO "no router on bridge\n")
> 
> There is a set of macro's already for use in bridging code:
>                 br_info(br, "no router on bridge\n");
> 

Never mind, removing these printk's is in my TODO list. :)
