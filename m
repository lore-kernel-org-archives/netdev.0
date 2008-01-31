From: Andi Kleen <ak@suse.de>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 16:04:27 +0100
Message-ID: <200801311604.28110.ak@suse.de>
References: <200801311321.01015.ak@suse.de> <47A1CD4E.7050701@trash.net> <47A1D4F2.6080904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:52455 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504AbYAaPFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 10:05:49 -0500
In-Reply-To: <47A1D4F2.6080904@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Works for me:
>
> qdisc tbf 8001: root rate 1000bit burst 10b/8 mpu 0b lat 720.0ms
>   Sent 0 bytes 0 pkt (dropped 9, overlimits 0 requeues 0)
>   rate 0bit 0pps backlog 0b 0p requeues 0
>
> Packets are dropped as expected.

I can still reproduce it on 64bit with http://halobates.de/config-qdisc
(all qdiscs etc. compiled in for testing) 
with latest git tip (8af03e782cae1e0a0f530ddd22301cdd12cf9dc0)

The command line above causes an instant hang. Also tried it with
newer iproute2 (the original one was quite old), but it didn't make
a difference.

Perhaps it's related to what qdiscs are enabled? Can you please
try with the above config?

If everything fails I can do a bisect later.

-Andi
