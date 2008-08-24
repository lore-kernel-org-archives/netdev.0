From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [bisected] Weird sysctl regression
Date: Sun, 24 Aug 2008 14:53:04 +0200
Message-ID: <87abf21snj.fsf@natisbad.org>
References: <87fxoyal9j.fsf@natisbad.org>
	<20080823084936.GK28946@ZenIV.linux.org.uk>
	<87wsi7en1m.fsf@natisbad.org>
	<20080823170248.GL28946@ZenIV.linux.org.uk>
	<87ljynd582.fsf@natisbad.org>
	<20080823181651.GM28946@ZenIV.linux.org.uk>
	<87od3jo2vn.fsf@natisbad.org>
	<20080824115424.GP28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:44527 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871AbYHXMyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2008 08:54:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Al Viro <viro@ZenIV.linux.org.uk> writes:

>> Sorry for the delay. Yes, no additional patches in both cases:
>> 
>> - stock 2.6.27-rc4 from kernel.org
>> - freshly cloned net-next-2.6 after David's announcement
>
> Gyah...  Dumb braino on my part.  That sucker should've gone into the
> global class, not the rotable stuff.  See if that helps...

It does! I just recompiled net-next-2.6 (2.6.27-rc4 based) with the
patch applied and my /proc/sys/net/ is as it should be, i.e. with a
single and usable 'ipv6' entry. 

Thanks for your work.

Cheers,

a+
