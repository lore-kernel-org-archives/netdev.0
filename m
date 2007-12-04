From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: cassini driver hw checksum errors with vlans
Date: Tue, 04 Dec 2007 15:08:53 +0100
Message-ID: <47555F75.5060409@balabit.hu>
References: <4746AE01.50409@balabit.hu>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:58067 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbXLDOI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 09:08:56 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 79FA3C155D
	for <netdev@vger.kernel.org>; Tue,  4 Dec 2007 15:08:55 +0100 (CET)
In-Reply-To: <4746AE01.50409@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laszlo Attila Toth wrote:
> When we use cassini driver without VLANs, it works as expected but when 
> about 100 VLANs are configured on this interface, the hardware checksum 
> fails.

I tried it that I "disable" the checksum on the hardver side, in fact, I 
used CHECKSUM_NONE instead of CHECKSUM_HW but in this case the driver 
allocated all available memory after receiving a few hundred MiB data.


Attila
