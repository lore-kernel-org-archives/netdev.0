From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 15:54:47 +0100
Message-ID: <20140221145447.GD25406@gmail.com>
References: <20140221100158.GA19594@gmail.com>
 <20140221102626.GC2870@minipsycho.orion>
 <20140221111257.GA25406@gmail.com>
 <20140221113753.GD2870@minipsycho.orion>
 <20140221120244.GB25406@gmail.com>
 <20140221130553.GE2870@minipsycho.orion>
 <20140221143114.GC25406@gmail.com>
 <20140221144827.GG2870@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:43171 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466AbaBUOzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 09:55:12 -0500
Received: by mail-la0-f48.google.com with SMTP id mc6so2363200lab.7
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 06:55:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221144827.GG2870@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 03:48:27PM +0100, Jiri Pirko wrote:
> Fri, Feb 21, 2014 at 03:31:14PM CET, tobias@waldekranz.com wrote:
> >On Fri, Feb 21, 2014 at 02:05:53PM +0100, Jiri Pirko wrote:
> >> Fri, Feb 21, 2014 at 01:02:44PM CET, tobias@waldekranz.com wrote:
> >> >On Fri, Feb 21, 2014 at 12:37:53PM +0100, Jiri Pirko wrote:
> >> >> Fri, Feb 21, 2014 at 12:12:57PM CET, tobias@waldekranz.com wrote:
> >> >> >> What "switch driver" are you reffering to?
> >> >> >> 
> >> >> >
> >> >> >The driver that is in charge of multiplexing packets from the switch
> >> >> >chip out to the port interfaces. It registers an rx-handler on eth0
> >> >> >and forwards packets to port[1-4] by reading a custom tag (similar to
> >> >> >802.1Q) inserted by the switch.
> >> >> 
> >> >> Allright, but what's the name? I would like to find it and see the code.
> >> >
> >> >There's not really a name :), but I have made the source available on github:
> >> >
> >> >https://github.com/wkz/switchcore
> >> 
> >> Are you aware of existing DSA infrastructure?
> >> 
> >
> >Yes I am, we have our reasons for using our own driver. Most of it
> >having to do with dynamic configuration, multiple hardware channel
> >support and a variety of exotic hardware setups.
> 
> Would not it be better to make DSA better in order to achieve your goal?
> 

Sure, that is something we are considering. But before we do that we
need to make sure that our model works, end-to-end, for all important
use-cases.

> >
> >Do you have any input on the original question?
> 
> I'm not really sure how to handle this. I fail to clearly understand the
> topology you are describing...
> 
> >
> >> >
> >> >The relevant parts for this discussion should be in sc_main.c.
> >> >
> >> >> 
> >> >> >
> >> >> >-- 
> >> >> >Thanks
> >> >> > - wkz
> >> >
> >> >-- 
> >> >Thanks
> >> > - wkz
> >
> >-- 
> >Thanks
> > - wkz

-- 
Thanks
 - wkz
