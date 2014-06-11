From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 0/4] bridge: multicast snooping
 patches / exports
Date: Tue, 10 Jun 2014 23:51:23 -0700 (PDT)
Message-ID: <20140610.235123.310487202447168937.davem@davemloft.net>
References: <1402158389-13239-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1402158389-13239-1-git-send-email-linus.luessing@web.de>
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
Date: Sat,  7 Jun 2014 18:26:25 +0200

> The first patch is simply a cosmetic patch. So far I (and maybe other=
s
> too?) have been regularly confusing these two structs, therefore I'd
> suggest renaming them and therefore making the follow-up patches easi=
er
> to understand and nicer to fit in.
> =

> The second patch fixes a minor issue, but probably not worth for stab=
le.
> =

> On the other hand the first two patches are also preparations for the=

> third and fourth patch:
> =

> These two patches are exporting functionality needed to marry the bri=
dge
> multicast snooping with the batman-adv multicast optimizations recent=
ly
> added for the 3.15 kernel, allowing to use these optimzations in comm=
on
> setups having a bridge on top of e.g. bat0, too. So far these bridged=

> setups would fall back to simple flooding through the batman-adv mesh=

> network for any multicast packet entering bat0.

Series applied, thank you.
