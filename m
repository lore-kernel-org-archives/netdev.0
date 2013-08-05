From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: don't try to update timers in case of
 broken MLD queries
Date: Mon, 05 Aug 2013 15:44:20 -0700 (PDT)
Message-ID: <20130805.154420.599165201115948715.davem@davemloft.net>
References: <1375741925-22179-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: pebolle@tiscali.nl, amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1375741925-22179-1-git-send-email-linus.luessing@web.de>
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
Date: Tue,  6 Aug 2013 00:32:05 +0200

> Currently we are reading an uninitialized value for the max_delay
> variable when snooping an MLD query message of invalid length and wou=
ld
> update our timers with that.
> =

> Fixing this by simply ignoring such broken MLD queries (just like we =
do
> for IGMP already).
> =

> This is a regression introduced by:
> "bridge: disable snooping if there is no querier" (b00589af3b04)
> =

> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Applied, thanks.
