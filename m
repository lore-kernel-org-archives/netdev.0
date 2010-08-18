From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 6/8] netfilter: ipt_CLUSTERIP: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 14:16:22 +0800
Message-ID: <AANLkTikSXnhqwPeCpv1xk-NUVCa94ZY3sE5j9iBz6Hmr@mail.gmail.com>
References: <1282107952-3624-1-git-send-email-xiaosuo@gmail.com> <1282111708.2456.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282111708.2456.11.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 18, 2010 at 2:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> This added test is not documented in your Changelog
>
> Please dont add such things not telling why you do it.
>
> I am not sure it is needed here, I dont know ipt_CLUSTERIP, but dont
> defrag takes place before it ?


You are right. ipt_CLUSTERIP relies on ip_conntrack, and defrag takes
place before it. Thanks. I'll post an update.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
