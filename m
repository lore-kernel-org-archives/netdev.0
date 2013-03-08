From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] bridge: do not expire mdb entry when
 bridge still uses it
Date: Fri, 08 Mar 2013 15:26:21 +0800
Message-ID: <1362727581.3237.4.camel@cr0>
References: <1362708423-23932-1-git-send-email-amwang@redhat.com>
	<20130308023151.GA27155@gondor.apana.org.au>
	<1362710646.9773.25.camel@cr0>
	<20130308024726.GA27319@gondor.apana.org.au>
	<1362715613.9773.29.camel@cr0>
	<20130308040853.GA27704@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130308040853.GA27704@gondor.apana.org.au>
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

On Fri, 2013-03-08 at 12:08 +0800, Herbert Xu wrote:
> On Fri, Mar 08, 2013 at 12:06:53PM +0800, Cong Wang wrote:
> > 
> > The mdst may be removed, however the BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)
> > is still set, because in br_multicast_ipv4_rcv():
> 
> But those packets are only meant for routers, which is why we
> have the br_multicast_is_router test above.
> 

Hmm, what the user experiences is the multicast traffic between the
bridge and some port is broken. Isn't this expected to work by default?

Or we can just change the default value of br->multicast_router to 2?

Thanks!
