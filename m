From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH v4] iproute2: add mdb sub-command to bridge
Date: Mon, 10 Dec 2012 11:13:40 +0800
Message-ID: <1355109220.11752.3.camel@cr0>
References: <1a884874-7123-401f-a53c-cc8e301b1ffe@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1a884874-7123-401f-a53c-cc8e301b1ffe@tahiti.vyatta.com>
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

On Fri, 2012-12-07 at 09:07 -0800, Stephen Hemminger wrote:
> 
> > 
> > 	# ./bridge/bridge mdb
> > 	bridge br0:
> > 	port eth0, group 224.8.8.9
> > 	port eth1, group 224.8.8.8
> 
> I like the ability to see what is going on. It would
> be good if there was also a monitor like hook to see new entries
> created and destroyed (later version).

I am working on a patch to implement RTM_NEWMDB and RTM_DELMDB, so we
will have this.

> 
> The output format should be one line per entry for easier
> parsing by utilities. Something similar to 'ip neigh show'
> 

Right, I will update this in v5.

Thanks!
