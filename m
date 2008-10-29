From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 10:19:33 +0100
Message-ID: <49082AA5.20801@trash.net>
References: <490824B3.20100@gmail.com> <4908264D.4030206@trash.net> <412e6f7f0810290209wa70b478p8beb8c3442b9fa82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60686 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbYJ2JTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:19:36 -0400
In-Reply-To: <412e6f7f0810290209wa70b478p8beb8c3442b9fa82@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Wed, Oct 29, 2008 at 5:01 PM, Patrick McHardy <kaber@trash.net> wrote:
>> The estimators needs
>> this since they're estimating the arrival rate.
>>
>>
> I do not agree with you. TC is only for sending packets. Why does its
> estimator estimating the arrival rate?

I suppose because they were intended for policing.
