From: David Miller <davem@davemloft.net>
Subject: Re: arm64 allmodconfig failures in nft_reject_bridge.c
Date: Thu, 13 Nov 2014 14:35:13 -0500 (EST)
Message-ID: <20141113.143513.785778562781935404.davem@davemloft.net>
References: <20141112233738.GB3815@sirena.org.uk>
	<20141113113320.GF3815@sirena.org.uk>
	<20141113114357.GA7857@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linaro-kernel@lists.linaro.org, coreteam@netfilter.org,
	kernel-build-reports@lists.linaro.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	broonie@kernel.org, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, linux@roeck-us.net
To: pablo@netfilter.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20141113114357.GA7857@salvia>
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

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 13 Nov 2014 12:43:57 +0100

> On Thu, Nov 13, 2014 at 11:33:20AM +0000, Mark Brown wrote:
>> Since about -rc3 we've been seeing build failures in Linus' tree on
>> arm64 allmodconfig due to:
>> 
>> > 	arm64-allmodconfig
>> > ../net/bridge/netfilter/nft_reject_bridge.c:240:3: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
>> 
>> By the time I looked into this it was fixed in -next by c1207c049b204b0
>> (netfilter: nft_reject_bridge: Fix powerpc build error) from Guenter but
>> that doesn't seem to have made it into -rc4 so I just wanted to check
>> that this fix was intended to go to Linus before v3.18?
> 
> I can see this in David's tree:
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=c1207c049b204b0a96535dc5416aee331b51e0e1
> 
> I think this was reported by when -rc4 was already out, so you'll see
> this by -rc5.

I hold changes in my tree for a week or more, because I want them to
"cook" there before they go to Linus.

So if it takes a week or two for a bug fix like this to propagate into
Linus's tree, that's just what sometimes happens.

In the mean time you can apply the fix locally if you absolutely have
to have it right at this moment, that is the freedom that everyone
has.

FWIW, I plan to push my tree to Linus some time today, so this will be
resolved in the next day or so.

Thanks.
