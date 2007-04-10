From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 13:09:20 +0200
Message-ID: <461B7060.8000407@trash.net>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>	 <20070409.114402.45491411.davem@davemloft.net>	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net> <1176202930.8459.81.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbXDJLJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 07:09:53 -0400
In-Reply-To: <1176202930.8459.81.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Tue, 2007-04-10 at 12:46 +0200, Patrick McHardy wrote:
> 
> 
>>The main advantage that we don't get more weird sysfs/proc/ioctl based
>>interfaces
> 
> 
> Please don't put me into a corner I don't want to be in ;) The new
> wireless stuff was completely designed using netlink. The sysfs
> interface to these two specific things was a concession since it used to
> exist before and we don't really have a fully functional userspace tool
> yet.


I know :) It was a few month ago when I noticed the new bonding
sysfs interface when I first thought that we really need this.

>> and use the same interface that is used for all other network
>>configuration, which f.e. will allow to add support for all software
>>devices to iproute without much effort, so you don't need 30 different
>>tools for configuring the different software device types anymore.
>>Additionally we get atomic setup/dumps and extensibility.
> 
> 
> I don't think wireless can get away without a new tool. So much stuff
> there. Look at
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless-dev.git;a=blob;f=include/linux/nl80211.h;hb=HEAD


Maybe not wireless, but bonding, briding, vlan, etun, possibly more.
