From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Sat, 05 Nov 2005 17:23:00 +0900 (JST)
Message-ID: <20051105.172300.76631287.yoshfuji@linux-ipv6.org>
References: <20051027121545.GA5530@gondor.apana.org.au>
	<20051027.235732.01166239.yoshfuji@linux-ipv6.org>
	<20051105063030.GA32385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au, miyazawa@linux-ipv6.org,
	kozakai@linux-ipv6.org
In-Reply-To: <20051105063030.GA32385@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <20051105063030.GA32385@gondor.apana.org.au> (at Sat, 5 Nov 2005 17:30:30 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Thu, Oct 27, 2005 at 11:57:32PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> > 
> > Well, I really care.
> > I strongly believe that we SHOULD NOT mix encrypted
> > packets and plain text packets at the same hook.
> > e.g. LOCAL_IN is NOT for decrypted plain text packets,
> > but for the original encrypted ones.
> 
> OK.  Would it be workable for you if LOCAL_IN only saw the decrypted
> packets without ever seeing the encrypted ones?

Miyazawa-san, Kozakai-san and I have discussed on this issue.
The answer is "maybe," but from the point of view of the original context,
it'd be better to let it see encrypted packet.
Miyazawa-san, Kozakai-san, please comment further details.
(I'm about to fly...)

--yoshfuji @ NRT(->YVR)
