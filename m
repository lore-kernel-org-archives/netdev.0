From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] cpts: add missing <linux/if_vlan.h>
Date: Sun, 06 Apr 2014 18:48:17 +0200
Message-ID: <53418551.1000507@redhat.com>
References: <1396785331-26875-1-git-send-email-slyich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Sergei Trofimovich <slyfox@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergei Trofimovich <slyich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396785331-26875-1-git-send-email-slyich@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/06/2014 01:55 PM, Sergei Trofimovich wrote:
> From: Sergei Trofimovich <slyfox@gentoo.org>
>
> gcc complains as:
>      drivers/net/ethernet/ti/cpts.c: In function 'cpts_match':
>      drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
>      drivers/net/ethernet/ti/cpts.c:266:12: note: each undeclared identifier is reported only once for each function it appears in
>      drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)
>
> Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: netdev@vger.kernel.org

Thanks, fix is already in net tree:

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=79eb9d28c9b22fa419e2c3f1b2cc6e285720ae41
