From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bridge: multicast snooping
	exports #2
Date: Tue, 08 Jul 2014 16:13:41 -0700 (PDT)
Message-ID: <20140708.161341.103939871003850198.davem@davemloft.net>
References: <1404704477-19448-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1404704477-19448-1-git-send-email-linus.luessing@web.de>
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
Date: Mon,  7 Jul 2014 05:41:15 +0200


"0/4"?  Surely you meant "0/2" :-)

> Some people pointed out to me that it might be helpful to add stubs f=
or
> the newly added multicast exports. That way e.g. batman-adv should co=
ntinue
> to be compile and useable without having to have a kernel compiled
> with bridge code in the future. This is what the first patch is suppo=
sed
> to do.
> =

> The second patch adds a third multicast export for the bridge which
> e.g. batman-adv is supposed to use, too, soon: Just like the bridge
> disables its multicast snooping activities if no querier is present,
> batman-adv needs to do the same if bridges are involved.
> =

> =

> These three exports should be the final ones needed to marry the brid=
ge
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
> for instance (now including the third export):
> =

> http://git.open-mesh.org/batman-adv.git/commitdiff/61e4f6af4b7a21ed40=
40f2e711d50c778e5b6d93?hp=3D6ae4281474675fbca5bedcf768972a32db586eb6

Series applied, thanks.
