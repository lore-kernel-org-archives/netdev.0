From: David Miller <davem@davemloft.net>
Subject: Re: bridge: multicast snooping patches / exports
Date: Thu, 22 May 2014 15:37:42 -0400 (EDT)
Message-ID: <20140522.153742.1822151259317153775.davem@davemloft.net>
References: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
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

From: Linus L=FCssing <linus.luessing@web.de>
Date: Wed, 21 May 2014 10:58:58 +0200

> These two patches are exporting functionality needed to marry the bri=
dge
> multicast snooping with the batman-adv multicast optimizations recent=
ly
> added for the 3.15 kernel, allowing to use these optimzations in comm=
on
> setups having a bridge on top of e.g. bat0, too. So far these bridged=

> setups would fall back to simple flooding through the batman-adv mesh=

> network for any multicast packet entering bat0.
> =

> More information about the batman-adv multicast optimizations current=
ly
> implemented can be found here:
> =

> http://www.open-mesh.org/projects/batman-adv/wiki/Basic-multicast-opt=
imizations
> =

> The integration on the batman-adv side could afterwards look like thi=
s,
> for instance:
> =

> http://git.open-mesh.org/batman-adv.git/commitdiff/576b59dd3e34737c70=
2e548b21fa72059262f796?hp=3Df95ce7131746c65fbcdffcf2089cab59e2c2f7ac

I'd really like to see some feedback from bridge folks before applying
this, thanks.
