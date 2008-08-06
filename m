From: jamal <hadi@cyberus.ca>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 06 Aug 2008 08:46:00 -0400
Message-ID: <1218026760.4755.60.camel@localhost>
References: <200808060042.53503.denys@visp.net.lb>
	 <200808061321.19560.denys@visp.net.lb> <1218020686.4755.42.camel@localhost>
	 <200808061426.36605.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:54499 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbYHFMwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 08:52:10 -0400
Received: by yx-out-2324.google.com with SMTP id 8so280416yxm.1
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 05:52:09 -0700 (PDT)
In-Reply-To: <200808061426.36605.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 14:26 +0300, Denys Fedoryshchenko wrote:

> Is it better like this?
> 
> Sure optind is up to you, for me it is not clear yet how it works.
> 
> Just i notice in iptables.c, function do_command where they set optind to zero 
> and in comments /*re-set optind to zero in case do_command gets called second 
> time */

I have done extensive testing with and with optind=0 and optind=1 and i
didnt see any breakage with either.

I have a feeling that setting optind to 0 in your case to avoid the
crash maybe hiding something else - but i cant find what that something
else is since i am just simulating what you are doing.
If the iptables folks have changed it to reset to 0, then I dont see any
harm in resetting. 

So ACK to both your patches.

cheers,
jamal
PS:- dont wanna sound anal - and you dont have to do this if you dont
have time; but if you put the resetting of optind and the flags in a
separate patch from the freeing, that would be even better.

