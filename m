From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: defines IPPROTO_* needed for module alias
 generation
Date: Thu, 06 Feb 2014 20:40:26 -0800 (PST)
Message-ID: <20140206.204026.748374158531633683.davem@davemloft.net>
References: <1391685000-7346-1-git-send-email-mq@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carlos@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mq@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391685000-7346-1-git-send-email-mq@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Moskyto Matejka <mq@suse.cz>
Date: Thu,  6 Feb 2014 12:10:00 +0100

> Commit cfd280c91253 ("net: sync some IP headers with glibc") changed a set of
> define's to an enum (with no explanation why) which introduced a bug
> in module mip6 where aliases are generated using the IPPROTO_* defines;
> mip6 doesn't load if require_module called with the aliases from
> xfrm_get_type().
> 
> Reverting this change back to define's to fix the aliases.
> 
> modinfo mip6 (before this change)
> alias:          xfrm-type-10-IPPROTO_DSTOPTS
> alias:          xfrm-type-10-IPPROTO_ROUTING
> 
> modinfo mip6 (after this change)
> alias:          xfrm-type-10-43
> alias:          xfrm-type-10-60
> 
> Signed-off-by: Jan Moskyto Matejka <mq@suse.cz>

I have to apply this, thanks Jan.
