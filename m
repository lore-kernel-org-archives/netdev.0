From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 12:12:57 +0100
Message-ID: <20140221111257.GA25406@gmail.com>
References: <20140221100158.GA19594@gmail.com>
 <20140221102626.GC2870@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:47774 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbaBULN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 06:13:26 -0500
Received: by mail-lb0-f176.google.com with SMTP id w7so2184396lbi.21
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 03:13:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221102626.GC2870@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What "switch driver" are you reffering to?
> 

The driver that is in charge of multiplexing packets from the switch
chip out to the port interfaces. It registers an rx-handler on eth0
and forwards packets to port[1-4] by reading a custom tag (similar to
802.1Q) inserted by the switch.

-- 
Thanks
 - wkz
