From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: arm64 allmodconfig failures in nft_reject_bridge.c
Date: Thu, 13 Nov 2014 12:43:57 +0100
Message-ID: <20141113114357.GA7857@salvia>
References: <E1Xm8gR-0005nT-PY@debutante> <20141106104616.GU8509@sirena.org.uk>
	<20141112233738.GB3815@sirena.org.uk>
	<20141113113320.GF3815@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: linaro-kernel@lists.linaro.org, kernel-build-reports@lists.linaro.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
To: Mark Brown <broonie@kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141113113320.GF3815@sirena.org.uk>
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

On Thu, Nov 13, 2014 at 11:33:20AM +0000, Mark Brown wrote:
> Since about -rc3 we've been seeing build failures in Linus' tree on
> arm64 allmodconfig due to:
>=20
> > 	arm64-allmodconfig
> > ../net/bridge/netfilter/nft_reject_bridge.c:240:3: error: implicit decl=
aration of function 'csum_ipv6_magic' [-Werror=3Dimplicit-function-declarat=
ion]
>=20
> By the time I looked into this it was fixed in -next by c1207c049b204b0
> (netfilter: nft_reject_bridge: Fix powerpc build error) from Guenter but
> that doesn't seem to have made it into -rc4 so I just wanted to check
> that this fix was intended to go to Linus before v3.18?

I can see this in David's tree:

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3Dc120=
7c049b204b0a96535dc5416aee331b51e0e1

I think this was reported by when -rc4 was already out, so you'll see
this by -rc5.
