From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2] iwlegacy: change IWL_WARN to IWL_DEBUG_HT in
 iwl4965_tx_agg_start
Date: Thu, 8 Sep 2011 18:11:30 +0200
Message-ID: <20110908161129.GC2195@redhat.com>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
 <20110829122013.GA3597@redhat.com>
 <4E5B9533.6000109@cuw.edu>
 <20110829140032.GA1573@redhat.com>
 <20110906150131.GA7322@redhat.com>
 <4E683BBE.3060105@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Dietsche <gregory.dietsche@cuw.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755158Ab1IHX3k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 19:29:40 -0400
Content-Disposition: inline
In-Reply-To: <4E683BBE.3060105@cuw.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg

On Wed, Sep 07, 2011 at 10:51:26PM -0500, Greg Dietsche wrote:
> On 09/06/2011 10:01 AM, Stanislaw Gruszka wrote:
> >I put patches here:
> >http://people.redhat.com/sgruszka/iwlegacy_cleanup.tar.bz2
> >
> >They are on top of wireless-testing tree.
> <snip>
> >Series include your 2 patches. You can test this cleanup and
> >apply your new changes on top. I'll not do any further cleanup
> >for some time now, perhaps continue when I got public git tree.
> >
> Thanks! I've re-worked my patches and you can find them here:
> http://www.gregd.org/stuff/linux/iwlegacy_cleanup_greg.tar.bz2
> 
> I also decided to play with github a little bit:
> git://github.com/dietsche/linux.git and pushed two branches:
>   1) wireless-next-iwlegacy-stanislaw - your patch set
>   2) wireless-next-iwlegacy-stanislaw-greg - a branch that has my
> additional patches.
> `git format-patch wireless-next-iwlegacy-stanislaw..wireless-next-iwlegacy-stanislaw-greg`
> will generate the patches that are in the link i posted above.

Cool!

> The first two patches in my series are the ones that I think folks
> should take a closer look at. The rest are pretty safe.

The second patch is ok. I'm not sure about first one, but we can get
rid of "ctx = il_rxon_ctx_from_vif(vif)" at all, because we have
only one context. Removing il_rxon_context structure from
iwlegacy driver is my long term plan, you can look at that
if you wish.

Thanks
Stanislaw
