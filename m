From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Thu, 26 Mar 2015 15:49:01 +0100
Message-ID: <1427381341.2801675.245582457.5499DAED@webmail.messagingengine.com>
References: <1427307255.3555533.245187845.14A187CD@webmail.messagingengine.com>
 <1427370594-18807-1-git-send-email-klamm@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Roman Gushchin <klamm@yandex-team.ru>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427370594-18807-1-git-send-email-klamm@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2015, at 12:49, Roman Gushchin wrote:
> This patch introduces new ipv6 sysctl: ra_default_route_mtu.
> If it's set (> 0), it defines per-route MTU for any new default route
> received by RA.
> 
> This sysctl will help in the following configuration: we want to use
> jumbo-frames for internal networks and default ethernet frames for
> default route. Per-route MTU can only lower per-link MTU, so link MTU
> should be set to ~9000 (statically or via RA).
> 
> Due to dynamic nature of RA, setting MTU for default route will require
> userspace agent, that will monitor changes of default route
> and (re)configure it. Not simple. The suggested sysctl solves this
> problem.
> 
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
