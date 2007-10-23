From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: git pull request from debian repo.
Date: Tue, 23 Oct 2007 17:01:54 +0200
Message-ID: <20071023150154.GA25314@scream.fatal.se>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at> <20071019144815.GB30444@scream.fatal.se> <471B90E5.1040108@trash.net> <20071023141838.GA25201@scream.fatal.se> <471E074E.8050805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maximilian attems <max@stro.at>, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:34245 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbXJWPGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:06:11 -0400
Content-Disposition: inline
In-Reply-To: <471E074E.8050805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 04:38:06PM +0200, Patrick McHardy wrote:
> Almost - the default behaviour shouldn't change IMO. Also please
> send a complete patch, not one on top of your old one.

Which "default behaviour"? ip addr flush or ip neigh flush behaviour?
Both of those should behave the same IMHO.

Defaulting to never bail out is causing problems in a bunch of firewalling
frontends which has been reported multiple times to both debian and ubuntu
(and possibly others I don't know about), and looping forever causes the
bootup to never finish.
Thats my reason for advocating not selecting the "loop forever" as the
default choice.

-- 
Regards,
Andreas Henriksson
