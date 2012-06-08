From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1 v2] Ethtool: Add EEE support
Date: Fri, 8 Jun 2012 18:19:27 +0100
Message-ID: <1339175967.2648.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339010124-23413-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eilong@broadcom.com>,
	<peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36860 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751695Ab2FHRTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 13:19:31 -0400
In-Reply-To: <1339010124-23413-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 22:15 +0300, Yuval Mintz wrote:
> This patch adds 2 new ethtool commands which can be
> used to manipulate network interfaces' support in
> EEE.
> 
> Output of 'get' has the following form:
> 
> 	EEE Settings for p2p1:
> 		EEE status: enabled - active
> 		Tx LPI: 1000 (us)
> 		Supported EEE link modes:  10000baseT/Full
> 		Advertised EEE link modes:  10000baseT/Full
> 		Link partner advertised EEE link modes:  10000baseT/Full
> 
> Thanks goes to Giuseppe Cavallaro for his original patch.
[...]

You're supposed to actually run the self-tests (make check):

make[1]: Entering directory `/home/bwh/src/ethtool'
E: ethtool --get-eee devname foo returns 1
FAIL: test-cmdline

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
