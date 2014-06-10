From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: 3.4.92 MTU issues
Date: Tue, 10 Jun 2014 14:16:54 -0700
Message-ID: <CAADnVQ+q3wFf=j0TY57d6Ux4GyGLr0bVCFHDgA45n9rXiEEzjg@mail.gmail.com>
References: <53975FF9.5070803@egervary.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: =?UTF-8?Q?Egerv=C3=A1ry_Gergely?= <gergely@egervary.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53975FF9.5070803@egervary.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cc-ing netdev

On Tue, Jun 10, 2014 at 12:43 PM, Egerv=C3=A1ry Gergely <gergely@egerva=
ry.hu> wrote:
> Hi,
>
> we have just upgraded our systems from 3.4.91 (longterm) to 3.4.92.
> Since then we are experiencing dozens of MTU-related network timeout
> issues. Reverting back to 3.4.91 fixes all of these problems.
>
> Both kernel versions are built from vanilla sources with the same
> .config. These can be highly reproduced over VPN tunnels or even over
> simple ethernet connections when using DNAT. (TCP port forward) It
> looks like MTU path discovery is somehow affected.
>
> ICMP is not filtered in our network. (For testing, we flushed all
> iptables rules, set all policies to ACCEPT, and problem still exists.=
)
> We do not use any special sysctl settings. Was there any changes
> related to packet forwarding or MTU discovery?

some combination of old kernel and backport of ("net: ipv4:
ip_forward: fix inverted local_df test") ?
just guessing

> Thank you in advance,
> --
> Gergely EGERVARY
> Network Administrator
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
