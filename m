From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHY down?
Date: Tue, 02 Aug 2011 12:01:08 +0100
Message-ID: <1312282868.2591.68.camel@deadeye>
References: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15718 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882Ab1HBLBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 07:01:11 -0400
In-Reply-To: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-02 at 11:24 +0200, Joakim Tjernlund wrote:
> I must be missing something obvious but I cannot find how
> to bring eth0's PHY down (link down) from user space.
> Tried various settings with ethtool and ifconfig eth0 down but it didn't help.

If you configure an interface down, and if the interface is not used for
remote management, then some drivers will turn the PHY off.  But there
is no general way to control this explicitly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

