From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 02/14] selinux: Better local/forward check in
 selinux_ip_postroute()
Date: Fri, 5 Sep 2008 18:51:46 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051851230.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903004854.15669.95990.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080903004854.15669.95990.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Sep 2008, Paul Moore wrote:

> It turns out that checking to see if skb->sk is NULL is not a very good
> indicator of a forwarded packet as some locally generated packets also have
> skb->sk set to NULL.  Fix this by not only checking the skb->sk field but also
> the IP[6]CB(skb)->flags field for the IP[6]SKB_FORWARDED flag.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
> 
>  security/selinux/hooks.c |   36 +++++++++++++++++++++++++++---------
>  1 files changed, 27 insertions(+), 9 deletions(-)

Acked-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
