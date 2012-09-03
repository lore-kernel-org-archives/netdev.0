From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 5/7] stmmac: add sysFs support
Date: Mon, 3 Sep 2012 13:44:27 +0100
Message-ID: <1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
	 <1346658422-1925-6-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52457 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751656Ab2ICMob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 08:44:31 -0400
In-Reply-To: <1346658422-1925-6-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-03 at 09:47 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the sysFs support.
> Some internal driver parameters can be tuned by using some
> entries exposed via sysFS. There parameter currently are,
> for example, for internal timers used to mitigate the rx/tx
> interrupts or for EEE.
[...]

Why are you not exposing these through the standard ethtool operations?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
