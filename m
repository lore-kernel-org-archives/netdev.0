From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] ipv4: netfilter: ipt_CLUSTERIP: fix buffer overflow
Date: Thu, 17 Mar 2011 20:15:06 +0800
Message-ID: <AANLkTimtsB0B98E2xcoJgRsPwSpwuG+ahT+LX0s1YwpX@mail.gmail.com>
References: <1299780740-32652-1-git-send-email-segoon@openwall.com>
 <AANLkTimPZJoCzz386e-4m0Y4khWGZirZguGFmuFYCrry@mail.gmail.com>
 <4D7F5CAC.6070006@trash.net> <20110317113229.GA7710@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org,
	security@kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110317113229.GA7710@albatros>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2011 at 7:32 PM, Vasiliy Kulikov <segoon@openwall.com> =
wrote:
> 'buffer' string is copied from userspace. =A0It is not checked whethe=
r it is
> zero terminated. =A0This may lead to overflow inside of simple_strtou=
l().
> Changli Gao suggested to copy not more than user supplied 'size' byte=
s.
>
> It was introduced before the git epoch. =A0Files "ipt_CLUSTERIP/*" ar=
e
> root writable only by default, however, on some setups permissions mi=
ght be
> relaxed to e.g. network admin user.
>
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Acked-by: Changli Gao <xiaosuo@gmail.com>


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
