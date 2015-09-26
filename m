From: Wolfgang Nothdurft <netdev@linux-dude.de>
Subject: Re: Forcing the output interface using ip6_route_output doesn't work
Date: Sat, 26 Sep 2015 17:51:48 +0200
Message-ID: <5606BF14.4070903@linux-dude.de>
References: <560552A7.40305@linux-dude.de>
 <5605B8DF.2070603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-dude.de ([213.179.141.24]:43354 "EHLO
	mail.linux-dude.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbIZQTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 12:19:18 -0400
In-Reply-To: <5605B8DF.2070603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.09.2015 um 23:13 schrieb David Ahern:
> On 9/25/15 7:56 AM, Wolfgang Nothdurft wrote:
>> It seems that the ip6_route_output(net, sk, fl6) kernel function ignores
>> the fl6.flowi6_oif parameter for the routing decision.
>
> It is considered, but a mismatch is not considered fatal.
>
> I think the attached should fix your problem.
>
>

Thanks, now it works as expected. :)

Wolfgang
