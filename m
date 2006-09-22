From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW,
 SIOCSIWPOWER and SIOCGIWPOWER
Date: Fri, 22 Sep 2006 13:16:05 +0200
Message-ID: <20060922131605.0edfd719@logostar.upir.cz>
References: <44F355DE.3000206@linux.intel.com>
	<20060921183040.12d679f2@logostar.upir.cz>
	<4512C133.7010509@linux.intel.com>
	<20060921203347.44d66563@logostar.upir.cz>
	<4512EE8D.708@linux.intel.com>
	<20060922001332.7ea0d30a@logostar.upir.cz>
	<451314AC.3070103@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56706 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932297AbWIVLQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 07:16:09 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <451314AC.3070103@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, 21 Sep 2006 15:39:40 -0700, mabbas pise:
> if the stack handle it then no need to know. When I call 
> ieee80211_register_hw with driver's channel, rate and txpower info. the 
> txpower values are overwritten by ieee80211_init_client. I get all the 
> txpower info from EEPROMin the NIC and they are different that what 
> d80211 default to. Is there is away to keep the value the driver passed 
> in ieee80211_register_hw?

Well, there is still a work to do here. See Larry Finger's proposal,
http://www.spinics.net/lists/netdev/msg05623.html - it's not ideal, there
are some problems with its design, but it's probably the way to go.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
