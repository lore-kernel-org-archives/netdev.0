From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9758] New: net_device refcnt bug when NFQUEUEing
 bridged packets
Date: Sun, 20 Jan 2008 14:58:46 +0100
Message-ID: <47935396.2080509@trash.net>
References: <bug-9758-10286@http.bugzilla.kernel.org/>	<20080115155655.d1a24eaf.akpm@linux-foundation.org>	<478D8DF5.7080901@trash.net>	<478D8F29.5040703@trash.net> <20080116105632.2532812c@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58474 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbYATN7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 08:59:47 -0500
In-Reply-To: <20080116105632.2532812c@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This looks good, but you could use a structure assignment rather memcpy
> (just a personal style preference because assignment is typed and memcpy
> is not).

That doesn't work in this case since nf_bridge_info contains

         unsigned long data[32 / sizeof(unsigned long)];

and I don't want to assign each array element seperately.
