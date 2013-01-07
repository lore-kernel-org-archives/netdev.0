From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next V2] ethtool: fix drvinfo strings set in drivers
Date: Sun, 06 Jan 2013 21:06:55 -0800 (PST)
Message-ID: <20130106.210655.1262628911724067629.davem@davemloft.net>
References: <1357469066-10620-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fbl@redhat.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab3AGFG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:06:57 -0500
In-Reply-To: <1357469066-10620-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  6 Jan 2013 11:44:26 +0100

> Use strlcpy where possible to ensure the string is \0 terminated.
> Use always sizeof(string) instead of 32, ETHTOOL_BUSINFO_LEN
> and custom defines.
> Use snprintf instead of sprint.
> Remove unnecessary inits of ->fw_version
> Remove unnecessary inits of drvinfo struct.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
