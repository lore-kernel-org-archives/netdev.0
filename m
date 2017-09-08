From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nat: constify rhashtable_params
Date: Fri, 8 Sep 2017 13:46:30 +0200
Message-ID: <20170908114630.GA13575@salvia>
References: <d978194ca83e9aa41a330a42442eecd8be9e9a60.1504093452.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fw@strlen.de, kadlec@blackhole.kfki.hu,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        coreteam@netfilter.org, netfilter-devel@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d978194ca83e9aa41a330a42442eecd8be9e9a60.1504093452.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 05:18:04PM +0530, Arvind Yadav wrote:
> rhashtable_params are not supposed to change at runtime. All
> Functions rhashtable_* working with const rhashtable_params
> provided by <linux/rhashtable.h>. So mark the non-const structs
> as const.

Applied to nf, thanks.
