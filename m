From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] inet6: minor cleanups
Date: Tue, 21 Jul 2009 12:57:45 -0700 (PDT)
Message-ID: <20090721.125745.210846096.davem@davemloft.net>
References: <inet6_minor_cleanups>
	<1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755548AbZGUT5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 15:57:40 -0400
In-Reply-To: <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 19 Jul 2009 20:23:35 +0200

> This is a small set of minor-cleanup patches, found while
> studying the tclass code.
> 
> Patch #1: Unifies return convention of datagram_send_ctl().

OK.

> Patch #2: Consolidates cmsg code for Traffic Class / Hop Limit.

You delete the 'addr_type' variable but that's rediculious.

The name of the variable describes what is held in it, now
that value gets stored in 'val' which makes the code harder
to read and understand.

I'm not applying this, it's noise, and on top of that it's
bad noise and makes the code worse.

> Patch #3: Simplifies assignments from u8 to int (no conversion).

OK.

> Patch #4: Finds that RT_TOS() redefines IPTOS_TOS().

This macro probably exists so that if the ipv4 route cache entry TOS
representation changes compared to IPTOS_TOS(), we would simply have
to change the definition of this macro.

Just because they happen to be the same now is no reason to kill off
this macro I think.

I'm not applying this either.
