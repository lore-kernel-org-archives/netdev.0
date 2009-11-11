From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: r8169: fix driver drop incoming packets >= 1515 if MTU is set
	between 1515 and 1536
Date: Wed, 11 Nov 2009 18:33:39 +0000
Message-ID: <1257964419.2839.58.camel@achroite.uk.solarflarecom.com>
References: <4AFB0061.7020908@apollo.lv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Raimonds Cicans <ray@apollo.lv>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10003 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758333AbZKKSdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 13:33:35 -0500
In-Reply-To: <4AFB0061.7020908@apollo.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-11 at 20:20 +0200, Raimonds Cicans wrote:
> Driver drop incoming packets >= 1515(1) if MTU is set between 1515(1) and 1536.
> 
> 1) exact number depends on some factors:
> - VLAN tagged or not
> - patch "r8169: Fix card drop incoming VLAN tagged MTU byte large jumbo frames"
>   applied or not
[...]

MTU is a limit on transmission; it is not required to limit received
frames.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

