From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCHv3 net-next 0/4] bridge: multicast snooping
 patches / exports
Date: Thu, 5 Jun 2014 23:20:16 +0200
Message-ID: <20140605212016.GE2544@Linus-Debian>
References: <1401732466-3027-1-git-send-email-linus.luessing@web.de>
	<20140602184215.GA2460@Linus-Debian>
	<20140605.004311.19890338095820543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140605.004311.19890338095820543.davem@davemloft.net>
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


On Thu, Jun 05, 2014 at 12:43:11AM -0700, David Miller wrote:
> From: Linus L=C3=BCssing <linus.luessing@web.de>
> Date: Mon, 2 Jun 2014 20:42:15 +0200
>=20
> > Changes in v3:
> >=20
> > * use EXPORT_SYMBOL_GPL() instead of EXPORT_SYMBOL()
>=20
> This is not a sufficient header posting.
>=20
> You must also describe at a high level what this patch series is
> doing, and why you are doing it.

Oh, I'm sorry, I thought it'd only be necessary for the v1
patchset. Going to change that from now on. Anyways, here it is
(copied 'n' pasted):

-----

The first patch is simply a cosmetic patch. So far I (and maybe others
too?) have been regularly confusing these two structs, therefore I'd
suggest renaming them and therefore making the follow-up patches easier
to understand and nicer to fit in.

The second patch fixes a minor issue, but probably not worth for stable.


On the other hand the first two patches are also preparations for the
third and fourth patch:

These two patches are exporting functionality needed to marry the bridge
multicast snooping with the batman-adv multicast optimizations recently
added for the 3.15 kernel, allowing to use these optimzations in common
setups having a bridge on top of e.g. bat0, too. So far these bridged
setups would fall back to simple flooding through the batman-adv mesh
network for any multicast packet entering bat0.

More information about the batman-adv multicast optimizations currently
implemented can be found here:

http://www.open-mesh.org/projects/batman-adv/wiki/Basic-multicast-optimiz=
ations

The integration on the batman-adv side could afterwards look like this,
for instance:

http://git.open-mesh.org/batman-adv.git/commitdiff/576b59dd3e34737c702e54=
8b21fa72059262f796?hp=3Df95ce7131746c65fbcdffcf2089cab59e2c2f7ac

-----
