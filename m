From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2: git pull request from debian repo.
Date: Tue, 23 Oct 2007 17:08:10 +0200
Message-ID: <471E0E5A.40306@trash.net>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at> <20071019144815.GB30444@scream.fatal.se> <471B90E5.1040108@trash.net> <20071023141838.GA25201@scream.fatal.se> <471E074E.8050805@trash.net> <20071023150154.GA25314@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: maximilian attems <max@stro.at>, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48064 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbXJWPJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:09:09 -0400
In-Reply-To: <20071023150154.GA25314@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Henriksson wrote:
> On Tue, Oct 23, 2007 at 04:38:06PM +0200, Patrick McHardy wrote:
>> Almost - the default behaviour shouldn't change IMO. Also please
>> send a complete patch, not one on top of your old one.
> 
> Which "default behaviour"? ip addr flush or ip neigh flush behaviour?
> Both of those should behave the same IMHO.

In both cases your changed behaviour should be optional and it should
default to the old behaviour. Not actually flushing completely when the
user specified "flush" is counter-intuitive.

> Defaulting to never bail out is causing problems in a bunch of firewalling
> frontends which has been reported multiple times to both debian and ubuntu
> (and possibly others I don't know about), and looping forever causes the
> bootup to never finish.
> Thats my reason for advocating not selecting the "loop forever" as the
> default choice.

Then those frontends should add "maxrounds N" if they want to abort
before the flush is complete.

