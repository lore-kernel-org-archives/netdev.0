From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
 and SIOCGIWPOWER
Date: Fri, 22 Sep 2006 08:24:23 -0500
Message-ID: <4513E407.50400@lwfinger.net>
References: <44F355DE.3000206@linux.intel.com> <20060921183040.12d679f2@logostar.upir.cz> <4512C133.7010509@linux.intel.com> <20060921203347.44d66563@logostar.upir.cz> <4512EE8D.708@linux.intel.com> <20060922001332.7ea0d30a@logostar.upir.cz> <451314AC.3070103@linux.intel.com> <20060922131605.0edfd719@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:39559 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932407AbWIVNY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 09:24:28 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060922131605.0edfd719@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> Thu, 21 Sep 2006 15:39:40 -0700, mabbas pise:
>> if the stack handle it then no need to know. When I call 
>> ieee80211_register_hw with driver's channel, rate and txpower info. the 
>> txpower values are overwritten by ieee80211_init_client. I get all the 
>> txpower info from EEPROMin the NIC and they are different that what 
>> d80211 default to. Is there is away to keep the value the driver passed 
>> in ieee80211_register_hw?
> 
> Well, there is still a work to do here. See Larry Finger's proposal,
> http://www.spinics.net/lists/netdev/msg05623.html - it's not ideal, there
> are some problems with its design, but it's probably the way to go.

That project is on hold now, but I'm willing to share the information I have and to participate in 
further developments.

Larry
