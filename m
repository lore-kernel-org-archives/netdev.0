From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipv6: netfilter: ip6_tables: fix infoleak to userspace
Date: Tue, 15 Mar 2011 13:37:44 +0100
Message-ID: <4D7F5D98.1060105@trash.net>
References: <1299780827-344-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299780827-344-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.03.2011 19:13, Vasiliy Kulikov wrote:
> Structures ip6t_replace, compat_ip6t_replace, and xt_get_revision are
> copied from userspace.  Fields of these structs that are
> zero-terminated strings are not checked.  When they are used as argument
> to a format string containing "%s" in request_module(), some sensitive
> information is leaked to userspace via argument of spawned modprobe
> process.
> 
> The first bug was introduced before the git epoch;  the second was
> introduced in 3bc3fe5e (v2.6.25-rc1);  the third is introduced by
> 6b7d31fc (v2.6.15-rc1).  To trigger the bug one should have
> CAP_NET_ADMIN.

Also applied, thanks Vasiliy.
