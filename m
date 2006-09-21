From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW, SIOCSIWPOWER
 and SIOCGIWPOWER
Date: Thu, 21 Sep 2006 12:57:01 -0700
Message-ID: <4512EE8D.708@linux.intel.com>
References: <44F355DE.3000206@linux.intel.com>	<20060921183040.12d679f2@logostar.upir.cz>	<4512C133.7010509@linux.intel.com> <20060921203347.44d66563@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:53692 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750918AbWIUT46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 15:56:58 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060921203347.44d66563@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> Thu, 21 Sep 2006 09:43:31 -0700, mabbas pise:
>   
>> What about adding a new callback function fot txpower. 
>> ieee80211_hw_config callback still confusing if txpower was
>> changed for channel change or because the user setting txpower limit.
>>     
>
> Why should the driver care?
>
>  Jiri
>
>   
if the user set txpoer using iwconfig command, the driver will clap all 
txpower to this
value for all available channels if channels original txpower is higher 
than txpower value.
Mohamed
