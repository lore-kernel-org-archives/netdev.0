From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic with time-stamping in phy devices
	(monitor mode)
Date: Fri, 10 Dec 2010 16:18:58 -0800 (PST)
Message-ID: <20101210.161858.209963634.davem@davemloft.net>
References: <1291551879.2806.253.camel@edumazet-laptop>
	<AANLkTinFEUd5vuBu98COXMRGMFcpwtu_dsw=_=cN6oZJ@mail.gmail.com>
	<1291611032.2806.310.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, richardcochran@gmail.com, akwatts@ymail.com,
        stable@kernel.org, xiaosuo@gmail.com
To: eric.dumazet@gmail.com
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1291611032.2806.310.camel@edumazet-laptop>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Dec 2010 05:50:32 +0100

> Le lundi 06 d=E9cembre 2010 =E0 08:01 +0800, Changli Gao a =E9crit :
> =

>> How about using skb_headroom(skb) < ETH_HLEN ?
>> =

> =

> Yes, good idea, thanks !
> =

> [PATCH net-2.6] net: fix skb_defer_rx_timestamp()
> =

> After commit c1f19b51d1d8 (net: support time stamping in phy devices.),
> kernel might crash if CONFIG_NETWORK_PHY_TIMESTAMPING=3Dy and
> skb_defer_rx_timestamp() handles a packet without an ethernet header.
> =

> Fixes kernel bugzilla #24102
> =

> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=3D24102
> Reported-and-tested-by: Andrew Watts <akwatts@ymail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
