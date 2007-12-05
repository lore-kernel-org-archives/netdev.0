From: Samir Bellabes <sam@synack.fr>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 05 Dec 2007 16:12:46 +0100
Message-ID: <m21wa118gh.fsf@synack.fr>
References: <20071205.053031.87154402.davem@davemloft.net>
	<4756B175.5010108@psc.edu> <20071205144843.GB2623@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>,
	David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220.235.97-84.rev.gaoland.net ([84.97.235.220]:59643 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbXLEPMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 10:12:45 -0500
In-Reply-To: <20071205144843.GB2623@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Wed, 5 Dec 2007 17:48:43 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> Hi.
>
> On Wed, Dec 05, 2007 at 09:11:01AM -0500, John Heffner (jheffner@psc.edu) wrote:
>> >Maybe if we want to get really fancy we can have some more-expensive
>> >debug mode where detailed specific events get generated via some
>> >macros we can scatter all over the place.  This won't be useful
>> >for general user problem analysis, but it will be excellent for
>> >developers.
>> >
>> >Let me know if you think this is useful enough and I'll work on
>> >an implementation we can start playing with.
>> 
>> 
>> FWIW, sounds similar to what these guys are doing with SIFTR for FreeBSD:
>> http://caia.swin.edu.au/urp/newtcp/tools.html
>> http://caia.swin.edu.au/reports/070824A/CAIA-TR-070824A.pdf
>
> And even more similar to this patch from Samir Bellabes of Mandriva:
> http://lwn.net/Articles/202255/

Indeed, I was thinking about this idea. but yet, my goal is not to deal
with specific protocols like TCP, it's just to deal with the LSM hooks.
Anyway, the idea is the same, having a deamon is userspace to catch
informations. So why not a expansion? 

Lately, I'm moving the code to generic netlink, from connector.
regards,
sam
