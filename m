From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 12:37:53 +0100
Message-ID: <20140221113753.GD2870@minipsycho.orion>
References: <20140221100158.GA19594@gmail.com>
 <20140221102626.GC2870@minipsycho.orion>
 <20140221111257.GA25406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Waldekranz <tobias@waldekranz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:64461 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbaBULh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 06:37:57 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so1513688ead.10
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 03:37:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221111257.GA25406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 21, 2014 at 12:12:57PM CET, tobias@waldekranz.com wrote:
>> What "switch driver" are you reffering to?
>> 
>
>The driver that is in charge of multiplexing packets from the switch
>chip out to the port interfaces. It registers an rx-handler on eth0
>and forwards packets to port[1-4] by reading a custom tag (similar to
>802.1Q) inserted by the switch.

Allright, but what's the name? I would like to find it and see the code.

>
>-- 
>Thanks
> - wkz
