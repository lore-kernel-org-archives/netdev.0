From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 12:23:03 +0100
Message-ID: <46026717.9060909@trash.net>
References: <20070321175951.M73913@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030333AbXCVLXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 07:23:05 -0400
In-Reply-To: <20070321175951.M73913@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Possible i discovered bug, but maybe specific to my setup. 
> 
> In your sources (tc/tc_core.h) i notice 
> #define TIME_UNITS_PER_SEC    1000000000 
> When i change it to 
> #define TIME_UNITS_PER_SEC      1000000.0 
> (it was value before in sources) 
> everythign works fine. Otherwise tbf not working at all, it is dropping all 
> packets.
> 
> Did anyone test new iproute2 with tbf?


Yes, please send the commands you use.
