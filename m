From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "ipv4: Make INET_LRO a bool instead of
 tristate."
Date: Sun, 03 Oct 2010 21:01:55 -0700 (PDT)
Message-ID: <20101003.210155.189686958.davem@davemloft.net>
References: <1286156262.3916.213.camel@localhost>
	<20101003.195618.193723845.davem@davemloft.net>
	<1286164495.3916.316.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37662
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750703Ab0JDEBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 00:01:34 -0400
In-Reply-To: <1286164495.3916.316.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 04 Oct 2010 04:54:55 +0100

> On Sun, 2010-10-03 at 19:56 -0700, David Miller wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Mon, 04 Oct 2010 02:37:42 +0100
>> 
>> > You made the change I want to revert in response to
>> > <http://article.gmane.org/gmane.linux.kernel/825646>.  The real problem
>> > with its configuration is actually that CONFIG_INET is not set but
>> > CONFIG_INET_LRO=m, and the fix is to make CONFIG_PASEMI_MAC depend on
>> > CONFIG_INET.
>> 
>> Ben, you can't just revert this by itself.
>> 
>> That knowingly breaks the build.
>> 
>> If you want the tristate back, you must do it after or at the
>> same time as fixing the driver deps.
> 
> The fact that the driver dependencies are broken has nothing to do with
> whether CONFIG_INET_LRO is boolean or tristate.  You fixed a problem
> that didn't exist rather than the problem that did.

Oh, I see, ok I'll apply your patches thanks for explaining Ben.
