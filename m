From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
 and SIOCGIWPOWER
Date: Thu, 21 Sep 2006 15:39:40 -0700
Message-ID: <451314AC.3070103@linux.intel.com>
References: <44F355DE.3000206@linux.intel.com>	<20060921183040.12d679f2@logostar.upir.cz>	<4512C133.7010509@linux.intel.com>	<20060921203347.44d66563@logostar.upir.cz>	<4512EE8D.708@linux.intel.com> <20060922001332.7ea0d30a@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:37902 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S932084AbWIUWkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 18:40:52 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060922001332.7ea0d30a@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Thu, 21 Sep 2006 12:57:01 -0700, mabbas wrote:
>   
>> if the user set txpoer using iwconfig command, the driver will clap all 
>> txpower to this
>> value for all available channels if channels original txpower is higher 
>> than txpower value.
>>     
>
> Looks like a job for the stack.
>
> If the stack takes care about that and always pass the correct value to a
> driver, is there still a reason for the driver to know where the request
> originated from?
>
>  Jiri
>
>   
if the stack handle it then no need to know. When I call 
ieee80211_register_hw with driver's channel, rate and txpower info. the 
txpower values are overwritten by ieee80211_init_client. I get all the 
txpower info from EEPROMin the NIC and they are different that what 
d80211 default to. Is there is away to keep the value the driver passed 
in ieee80211_register_hw?
Mohamed
