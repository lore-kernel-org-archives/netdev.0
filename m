From: Patrick McHardy <kaber@trash.net>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 12:28:55 +0200
Message-ID: <49F042E7.7060900@trash.net>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net> <alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, "Y. D." <duyuyang@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46423 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570AbZDWK3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 06:29:01 -0400
In-Reply-To: <alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Thursday 2009-04-23 12:20, Patrick McHardy wrote:
> 
>>>> Is IMQ still maintained? I am using IMQ to shape ingress traffic.
>>>> But the application is a streaming server (VLC). However, the kernel
>>>> reboots immediately as quick as can hardly been seen what is
>>>> wrong with it.
>>>>
>>>> Any help with this kinda problem?
>>> IMQ isn't a part of kernel/netfilter, so you should try at its own
>>> site/mailing list.
>> I'd rather suggest to get rid of it and use ifb, AFAIK there hasn't
>> been a single version in all those years that didn't cause this kind
>> of problems.
> 
> I'd rather point out that ifb does not seem to be able to do all of what 
> IMQ can, up to the point where it is believed in the public that ifb is 
> practically useless.

I'm aware of those claims, but not of the details. If this is true,
people should raise those issues and help resolve them. I wouldn't
hold my breath waiting for IMQ to get fixed.

