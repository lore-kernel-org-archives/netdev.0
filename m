From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER] Fix "undefined reference" error if
 CONFIG_SYSCTL=n
Date: Fri, 10 Sep 2004 15:10:29 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040910151029.7795e336.davem@davemloft.net>
References: <20040910.153135.121099678.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040910.153135.121099678.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Sep 2004 15:31:35 +0900 (JST)
YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B <yoshfuji@linux-ipv6.org> wrote:

> Fix the following error if CONFIG_SYSCTL=3Dn.
>=20
> | net/built-in.o: In function `tcp_in_window':
> | net/built-in.o(.text+0x49571): undefined reference to `ip_ct_log_invali=
d'
 ...=20
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks.
