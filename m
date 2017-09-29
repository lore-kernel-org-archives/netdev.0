From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] ebtables: fix race condition in
 frame_filter_net_init()
Date: Fri, 29 Sep 2017 13:29:18 +0200
Message-ID: <20170929112918.GA6066@salvia>
References: <20170926153923.30094-1-asavkov@redhat.com>
 <20170926163545.3668-1-asavkov@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Artem Savkov <asavkov@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170926163545.3668-1-asavkov@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 06:35:45PM +0200, Artem Savkov wrote:
> It is possible for ebt_in_hook to be triggered before ebt_table is assigned
> resulting in a NULL-pointer dereference. Make sure hooks are
> registered as the last step.

Applied, thanks.
