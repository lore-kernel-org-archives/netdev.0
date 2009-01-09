From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] ethtool: Support arbitrary speeds
Date: Fri, 09 Jan 2009 10:40:09 -0800
Message-ID: <49679A09.8070105@hp.com>
References: <200901080203.SAA19103@tardy.cup.hp.com>	<1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>	<49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com>	<1231442701.3893.4.camel@achroite>  <496658EB.1080206@hp.com>	<1231506974.3006.18.camel@achroite>  <49678FAB.3040007@hp.com> <1231525443.3006.35.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:41458 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbZAISkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 13:40:14 -0500
In-Reply-To: <1231525443.3006.35.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>Doesn't that need to keep the reporting of the unknown speed in parens 
>>like the original?
> 
> 
> We'll only be doing it for known invalid values, so the value isn't
> useful information.  I suppose it's conceivable that there are tools out
> there that are parsing the output and expect "Unknown! (0)" when link is
> down.

That was my paranoid assumption :) (albeit for the 65535 value :)

rick
