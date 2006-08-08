From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 2.6.18-rc3-mm2: bad e1000 device name
Date: Tue, 08 Aug 2006 01:16:14 -0700
Message-ID: <44D8484E.9050904@goop.org>
References: <44D78A48.7050707@goop.org> <20060808004011.ab3cd65f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:5805 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S932552AbWHHIQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 04:16:10 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060808004011.ab3cd65f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> e1000 seems OK here.  Don't know, sorry.
>   

It's happening to all my ethernet-like devices: the Atheros wireless 
comes up as a mess too.  It's different each time, so it looks like 
random uninitialized crud.

I did a clean rebuild, but it still happens.  I guess I'll have to try 
with some slab debugging and see if its an overrun or something.

    J
