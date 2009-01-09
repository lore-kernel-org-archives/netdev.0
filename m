From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Support arbitrary speeds
Date: Fri, 09 Jan 2009 18:24:03 +0000
Message-ID: <1231525443.3006.35.camel@achroite>
References: <200901080203.SAA19103@tardy.cup.hp.com>
	 <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
	 <49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com>
	 <1231442701.3893.4.camel@achroite>  <496658EB.1080206@hp.com>
	 <1231506974.3006.18.camel@achroite>  <49678FAB.3040007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52739 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753462AbZAISYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 13:24:13 -0500
In-Reply-To: <49678FAB.3040007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 09:55 -0800, Rick Jones wrote:
> Ben Hutchings wrote:
[...]
> > +	speed = ethtool_cmd_speed(ep);
> > +	if (speed == 0 || speed == (u16)(-1) || speed == (u32)(-1))
> > +		fprintf(stdout, "Unknown!\n");
> 
> Doesn't that need to keep the reporting of the unknown speed in parens 
> like the original?

We'll only be doing it for known invalid values, so the value isn't
useful information.  I suppose it's conceivable that there are tools out
there that are parsing the output and expect "Unknown! (0)" when link is
down.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

