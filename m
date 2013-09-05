From: David Miller <davem@davemloft.net>
Subject: Re: bride: IPv6 multicast snooping enhancements
Date: Thu, 05 Sep 2013 12:36:26 -0400 (EDT)
Message-ID: <20130905.123626.1950323953517801491.davem@davemloft.net>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
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
Date: Wed,  4 Sep 2013 02:13:37 +0200

> Here are two, small feature changes I would like to submit to increas=
e
> the usefulness of the multicast snooping of the bridge code.
> =

> The first patch is an unaltered one I had submitted before, but since=
 it
> got no feedback I'm resubmitting it here for net-next. With the recen=
tly
> added patch to disable snooping if there is no querier (b00589af + 24=
8ba8ec05
> + 8d50af4fb), it should be a safe choice now (without these, patch 1/=
2 would
> have introduced another potential for lost IPv6 multicast packets).
> =

> Both conceptually and also with some testing and fuzzing, I couldn't =
spot
> any more causes for potential packet loss. And since the multicast sn=
ooping
> code has now been tried by various people, I think it should be a saf=
e
> choice to apply the multicast snooping not only for IPv6 multicast pa=
ckets
> with a scope greater than link-local, but also for packets of exactly=
 this
> scope. The IPv6 standard mandates MLD reports for link-local multicas=
t, too,
> so we can safely snoop them as well (in contrast to IPv4 link-local).=


Both patches applied, thanks!
