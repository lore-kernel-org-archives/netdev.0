From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH] net: fix bridge multicast packet checksum
	validation
Date: Thu, 18 Feb 2016 14:36:44 +0100
Message-ID: <20160218133644.GL3010@otheros>
References: <1455502026-23144-1-git-send-email-linus.luessing@c0d3.blue>
	<20160218125134.GA20283@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	=?utf-8?B?w4FsdmFybyBGZXJuw6FuZGV6?= Rojas <noltari@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160218125134.GA20283@sesse.net>
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

On Thu, Feb 18, 2016 at 01:51:34PM +0100, Steinar H. Gunderson wrote:
> On Mon, Feb 15, 2016 at 03:07:06AM +0100, Linus L=C3=BCssing wrote:
> > Steinar, can you check whether this fixes the bridge issues you repor=
ted on
> > bugzilla #99081? Not quite sure whether it is the same as yours as yo=
u
> > do not seem to have any such call traces.
>=20
> It doesn't immediately sound like the same problem; why would promisc c=
hange
> anything if the problem is the checksumming?

The mdb you provided in the bugzilla ticket misses reports, so it
was unable to parse reports. Which could point to a checksumming
problem.

Enabling promisc probably did not fix the parsing for you, but instead
promisc forces to forward packets upstream on your interface independent
of the mdb. I would assume that even with promisc, your output
from "bridge mdb show" looks rather empty. Can you check?

>=20
> I don't have any reboots scheduled for this machine right now, but I'll=
 see
> what I can do wrt. testing.

Thanks :).
