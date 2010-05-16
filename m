From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system
 (2.6.33.3)
Date: Sun, 16 May 2010 13:24:07 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B7814753B@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1274040928.2299.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'Krzysztof Oledzki'" <ole@ans.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1483 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752474Ab0EPUYN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:24:13 -0400
In-Reply-To: <1274040928.2299.17.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet write:

> > I think that ICMP ping packets will always go to ring 0 (eth1-0)
> > because they are non-IP packets.  I need to double check tomorrow
> > on how exactly the hashing works on RX.  Can you try running IP
> > traffic?  IP packets should theoretically go to rings 1 - 4.
> >
>
> ICMP packets are IP packets (Protocol=1)
>

Sorry, Eric is right.  Anyway, I'll check on the hashing to see how
it works on UDP, TCP, and other packets.

