From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netfilter-core] [PATCH] netfilter: nat: constify
 rhashtable_params
Date: Fri, 8 Sep 2017 19:47:18 +0200
Message-ID: <20170908174718.GA1727@salvia>
References: <d978194ca83e9aa41a330a42442eecd8be9e9a60.1504093452.git.arvind.yadav.cs@gmail.com>
 <20170908114630.GA13575@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
        kadlec@blackhole.kfki.hu, davem@davemloft.net
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908114630.GA13575@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 01:46:30PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Aug 30, 2017 at 05:18:04PM +0530, Arvind Yadav wrote:
> > rhashtable_params are not supposed to change at runtime. All
> > Functions rhashtable_* working with const rhashtable_params
> > provided by <linux/rhashtable.h>. So mark the non-const structs
> > as const.
> 
> Applied to nf, thanks.

Actually, I tossed this. NAT rhashtable has been reverted, so no need
for this constification anymore.
