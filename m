From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] Revert "bridge: only expire the mdb entry when
	query is received"
Date: Mon, 21 Oct 2013 20:02:23 -0700
Message-ID: <CAM_iQpUq3EUu8GWsqbm_j9NonMGuWy0Qfimq1But9WrPsK8rbA@mail.gmail.com>
References: <1382223537-10844-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1382223537-10844-1-git-send-email-linus.luessing@web.de>
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

On Sat, Oct 19, 2013 at 3:58 PM, Linus L=C3=BCssing <linus.luessing@web.de>=
 wrote:
> While this commit was a good attempt to fix issues occuring when no
> multicast querier is present, this commit still has two more issues:
>
> 1) There are cases where mdb entries do not expire even if there is a
> querier present. The bridge will unnecessarily continue flooding
> multicast packets on the according ports.
>
> 2) Never removing an mdb entry could be exploited for a Denial of
> Service by an attacker on the local link, slowly, but steadily eating up
> all memory.
>

I raised the first issue too when I sent the patch, but Herbert said
it is not a problem. So, I will leave this to Herbert to decide.

For me, your patch makes sense.

Thanks.
