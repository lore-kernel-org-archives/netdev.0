From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN patch:  Export symbols as non GPL symbols.
Date: Mon, 26 Jan 2009 18:05:53 +0100
Message-ID: <497DED71.50900@trash.net>
References: <497DEC7A.1040405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48430 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbZAZRF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:05:57 -0500
In-Reply-To: <497DEC7A.1040405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> In previous kernels, any kernel module could get access to the 
> 'real-device' and the
> VLAN-ID for a particular VLAN.  In more recent kernels, the code was 
> restructured
> such that this is hard to do without accessing private .h files for any 
> module that cannot
> use GPL-only symbols.
> 
> Attached is a patch to once again allow non-GPL modules the ability to 
> access the
> real-device and VLAN id for VLANs.  This patch is against 2.6.29-rc2.
> 
> Signed-Off-By:  Ben Greear<greearb@candelatech.com>

I added that export after moving the code from a header file, but
there's no reason from my side not to export this to non-GPLed
drivers, using _GPL was merely a habit.

Acked-by: Patrick McHardy <kaber@trash.net>
