From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 21:09:45 +0100
Message-ID: <4793AA89.40507@fr.ibm.com>
References: <200801202053.30386.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:60190 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755673AbYATULy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 15:11:54 -0500
In-Reply-To: <200801202053.30386.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> My workstation running 2.6.24-rc8 just hung during shutdown with an endless 
> (or rather I didn't wait more than a few minutes) loop of 
> 
> unregister_netdev: waiting for ppp-device to become free. Usage count = 1
> 
> ppp-device was an active PPPoE device.
> 
> No more information currently.
> 
> -Andi
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I think this bug has been identified.

[Bug 9778] New: unregister_netdevice: waiting for [device] to become free

Thanks.
   -- Daniel
