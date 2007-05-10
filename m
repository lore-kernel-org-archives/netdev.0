From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: support for bridging ethernet and 802.11
Date: Thu, 10 May 2007 13:25:05 -0500
Message-ID: <04037A3C-17A3-46BB-BCE9-4BC880BF4FDF@kernel.crashing.org>
References: <CCA1D7C0-D44A-450D-A76E-DAE792E0CB37@kernel.crashing.org> <1178816781.3806.31.camel@johannes.berg> <20070510171213.GD24712@devicescape.com> <1178817575.3806.36.camel@johannes.berg> <20070510172510.GE24712@devicescape.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:12150 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751044AbXEJSZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 14:25:54 -0400
In-Reply-To: <20070510172510.GE24712@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 10, 2007, at 12:25 PM, Jouni Malinen wrote:

> On Thu, May 10, 2007 at 07:19:35PM +0200, Johannes Berg wrote:
>
>> Ah forgot about that, I had only thought about AP/wired bridging. How
>> would the prism driver actually do bridging in STA mode though?
>
> If that is referring to Host AP driver, there is support for using WDS
> in client mode. If the AP understands this, the client could use
> standard frames for its own packets (i.e., SA=own MAC addr) and WDS
> frames for frames from all other addresses. There are some  
> experimental
> modes in Host AP driver that (if I remember correctly ;-) may allow  
> this
> to be used on a single netdev (i.e., no additional netdev needed  
> for the
> WDS link) and as such, this would look like working layer 2 bridging
> between wlan0 and eth0 even in managed mode.

I'm a little confused.  It seems from the thread that there are  
several forums of bridging.

What I'm trying to accomplish is to take all traffic from eth0 to  
wlan0 (and the other way around).  I'm happy to configure and  
associate wlan0 with an AP.

I believe the current USB adapter I've got is using the SOFTMAC code  
right now.

- k
