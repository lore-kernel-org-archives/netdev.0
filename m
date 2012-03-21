From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 4/4] ath9k:  Support ethtool getstats api.
Date: Wed, 21 Mar 2012 16:10:57 +0000
Message-ID: <1332346257.3500.9.camel@deadeye>
References: <1332183105-4447-1-git-send-email-greearb@candelatech.com>
	 <1332183105-4447-4-git-send-email-greearb@candelatech.com>
	 <4F684301.9040006@openwrt.org> <4F68B4AA.3070306@candelatech.com>
	 <20329.32334.162938.169995@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:52420 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753776Ab2CUQLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 12:11:08 -0400
In-Reply-To: <20329.32334.162938.169995@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-21 at 12:37 +0530, Sujith Manoharan wrote:
> Ben Greear wrote:
> > I'd like to gather at least most stats always, so ethtool can work regardless
> > of debugfs.  But, that can be follow on patches in my opinion.  If it turns
> > out that we need another config option for this, then that is fine too.
> 
> It would be good to have an option to compile this out. The information is
> available via the debugfs interface, so this is basically duplicating things.
> On APs using OpenWRT, debugfs is enabled by default, so we can just read
> the debugfs files.

ethtool is the normal way to expose extended network stats, so the
debugfs interface should be dropped in favour of this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
