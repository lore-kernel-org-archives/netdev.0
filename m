From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5] bridge: export multicast database
 via netlink
Date: Tue, 11 Dec 2012 16:48:56 -0800
Message-ID: <20121211164856.37ce94fe@nehalam.linuxnetplumber.net>
References: <1354874688-24564-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1354874688-24564-1-git-send-email-amwang@redhat.com>
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

On Fri,  7 Dec 2012 18:04:48 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> V5: fix two bugs pointed out by Thomas
>     remove seq check for now, mark it as TODO
> 
> V4: remove some useless #include
>     some coding style fix
> 
> V3: drop debugging printk's
>     update selinux perm table as well
> 
> V2: drop patch 1/2, export ifindex directly
>     Redesign netlink attributes
>     Improve netlink seq check
>     Handle IPv6 addr as well
> 
> This patch exports bridge multicast database via netlink
> message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
> We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).
> 
> (Thanks to Thomas for patient reviews)
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>     

Applied, but required some manual fixing. It required adding if_bridge.h
to include/linux in iproute2 exported headers. Also patch still had some fuzz
against current version.
