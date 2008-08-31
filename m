From: Daniele Lacamera <root@danielinux.net>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 23:35:54 +0200
Message-ID: <48BB0EBA.6050606@danielinux.net>
References: <48BAE26A.4060002@danielinux.net> <20080831190916.GA15931@2ka.mipt.ru> <48BAEECA.80906@danielinux.net> <20080831202238.GA12624@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, angelo.tornese@gmail.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:4064 "EHLO
	mail.danielinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758368AbYHaVfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 17:35:48 -0400
In-Reply-To: <20080831202238.GA12624@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi Daniele.
>
> This actually may be not a big problem, since we allocate and free
> objects all the time, but still it is additional overhead which can be
> avoided. Did you run some perfromance analysis to check if influence is
> small or not visible at all?
>   
Evgeniy, thanks for pointing out the issue.

On my virtual machine (kvm), the alloc operation always takes less than 
one jiffie, but I can't say exactly how long. Is there a way to measure 
fast path time more accurately (e.g. nanoseconds)?


