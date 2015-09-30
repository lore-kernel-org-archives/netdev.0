From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/90] Netfilter/IPVS updates for net-next
Date: Tue, 29 Sep 2015 21:48:35 -0700 (PDT)
Message-ID: <20150929.214835.192307345267282932.davem@davemloft.net>
References: <1443554721-11554-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbbI3Esg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:48:36 -0400
In-Reply-To: <1443554721-11554-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 29 Sep 2015 21:25:21 +0200

> Hi David,
> 
> The following pull request contains Netfilter/IPVS updates for net-next
> containing 90 patches from Eric Biederman.
> 
> The main goal of this batch is to avoid recurrent lookups for the netns
> pointer, that happens over and over again in our Netfilter/IPVS code. The idea
> consists of passing netns pointer from the hook state to the relevant functions
> and objects where this may be needed.
> 
> You can find more information on the IPVS updates from Simon Horman's commit
> merge message:
> 
> c3456026adc0 ("Merge tag 'ipvs2-for-v4.4' of https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next").
> 
> Exceptionally, this time, I'm not posting the patches again on netdev, Eric
> already Cc'ed this mailing list in the original submission. If you need me to
> make, just let me know.

Yeah that's appropriate in this situation.

Pulled, thanks Pablo.
