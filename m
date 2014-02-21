From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 15:31:14 +0100
Message-ID: <20140221143114.GC25406@gmail.com>
References: <20140221100158.GA19594@gmail.com>
 <20140221102626.GC2870@minipsycho.orion>
 <20140221111257.GA25406@gmail.com>
 <20140221113753.GD2870@minipsycho.orion>
 <20140221120244.GB25406@gmail.com>
 <20140221130553.GE2870@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:61583 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbaBUObj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 09:31:39 -0500
Received: by mail-la0-f49.google.com with SMTP id y1so2337285lam.8
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 06:31:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221130553.GE2870@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 21, 2014 at 02:05:53PM +0100, Jiri Pirko wrote:
> Fri, Feb 21, 2014 at 01:02:44PM CET, tobias@waldekranz.com wrote:
> >On Fri, Feb 21, 2014 at 12:37:53PM +0100, Jiri Pirko wrote:
> >> Fri, Feb 21, 2014 at 12:12:57PM CET, tobias@waldekranz.com wrote:
> >> >> What "switch driver" are you reffering to?
> >> >> 
> >> >
> >> >The driver that is in charge of multiplexing packets from the switch
> >> >chip out to the port interfaces. It registers an rx-handler on eth0
> >> >and forwards packets to port[1-4] by reading a custom tag (similar to
> >> >802.1Q) inserted by the switch.
> >> 
> >> Allright, but what's the name? I would like to find it and see the code.
> >
> >There's not really a name :), but I have made the source available on github:
> >
> >https://github.com/wkz/switchcore
> 
> Are you aware of existing DSA infrastructure?
> 

Yes I am, we have our reasons for using our own driver. Most of it
having to do with dynamic configuration, multiple hardware channel
support and a variety of exotic hardware setups.

Do you have any input on the original question?

> >
> >The relevant parts for this discussion should be in sc_main.c.
> >
> >> 
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
