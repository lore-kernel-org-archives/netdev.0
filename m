From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net] bridge: Fix memory leak in br_dev_xmit
Date: Sun, 30 Mar 2014 11:41:35 +0900
Message-ID: <1396147295.2182.12.camel@localhost.localdomain>
References: <1395987680-8151-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<20140328093457.5d25b9a3@samsung-9>
	<1396078847.1756.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S . Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1396078847.1756.1.camel@localhost.localdomain>
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

On Sat, 2014-03-29 at 16:40 +0900, Toshiaki Makita wrote:
> On Fri, 2014-03-28 at 09:34 -0700, Stephen Hemminger wrote:
> > On Fri, 28 Mar 2014 15:21:19 +0900
> > Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> > 
> > > When a frame is rejected by br_allowed_ingress(), the skb is not freed.
> > > 
> ...
> > Increment dev->tx_dropped?
> 
> OK, I'll rework it.

After investigating bridge codes, I found br_cpu_netstats doesn't have
tx_dropped field.
I'm thinking about adding that field, but it seems to be appropriate for
net-next. I'm resending this patch as is for now.

Thanks,
Toshiaki Makita
