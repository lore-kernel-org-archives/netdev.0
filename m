From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 11:30:06 -0800
Message-ID: <20041217113006.3cbae2ba.davem@davemloft.net>
References: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>
	<41C2DCBC.1080302@dbservice.com>
	<20041217111634.740d4d46.davem@davemloft.net>
	<41C334DF.107@dbservice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bryan@coverity.com, jmorris@redhat.com, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Tomas Carnecky <tom@dbservice.com>
In-Reply-To: <41C334DF.107@dbservice.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004 20:34:55 +0100
Tomas Carnecky <tom@dbservice.com> wrote:

>  > It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
>  > replace iptables rules :)
> For me it seems that only CAP_NET_ADMIN is checked and not the data.

If that's the case then I agree with you Tomas.
