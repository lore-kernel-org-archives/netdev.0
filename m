From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next] bridge: implement multicast fast leave
Date: Tue, 04 Dec 2012 17:55:24 +0800
Message-ID: <1354614924.15167.9.camel@cr0>
References: <1354545363-11953-1-git-send-email-amwang@redhat.com>
	<20121203075316.0b1da39d@nehalam.linuxnetplumber.net>
	<20121204013838.GA31329@gondor.apana.org.au>
	<1354604692.15167.7.camel@cr0>
	<20121204070732.GA32550@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121204070732.GA32550@gondor.apana.org.au>
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

On Tue, 2012-12-04 at 15:07 +0800, Herbert Xu wrote:
> On Tue, Dec 04, 2012 at 03:04:52PM +0800, Cong Wang wrote:
> >
> > Per-port sounds better than per-bridge. And I will make it enabled by
> > default.
> 
> IMHO the default should be off.  Suddenly losing your subscription
> because someone else on the same port unsubscribed is a lot more
> annoying than getting a few minutes of unwanted multicast data.
> 

You are right, this is why it should only be used when there is one
client behind the port.

Thanks!
