From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Remove IPv6 ND prefix on ethernet disconnect?
Date: Thu, 23 Jun 2011 01:33:11 +0200
Message-ID: <20110622233311.GB19903@nuttenaction>
References: <20110622214129.GA30521@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33186 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757961Ab1FVXdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 19:33:13 -0400
Content-Disposition: inline
In-Reply-To: <20110622214129.GA30521@prithivi.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Harald Welte | 2011-06-22 23:41:29 [+0200]:

>My point is: If it's the kernel that automatically adds it, why is it
>not the kernel that automatically deletes it when it is no longer safe
>to assume it is valid (such as after loosing the link)?

Is loosing the link a sufficient criterion to restart ND? IMHO it is superior
to keep the same IP address (I assume privacy extension enabled) in the same
network if you lose the link artificial.

Environments where the link goes down and up again may suffer from such a
behavior. Maybe a script in Network Manager may be the better place. For me it
sounds like a policy thing which should not handled in the kernel.

But yes Harald, I understand your objection! ;-)

Hagen
