From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 18:18:22 +0100
Message-ID: <1293038302.3027.281.camel@edumazet-laptop>
References: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
	 <1293005302.4317.19.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F3327@MILEXCH2.ds.jdsu.net>
	 <1293033558.3027.216.camel@edumazet-laptop>
	 <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F33D3@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "juice@swagman.org" <juice@swagman.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37523 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab0LVRS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 12:18:26 -0500
Received: by wyb28 with SMTP id 28so5253009wyb.19
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 09:18:25 -0800 (PST)
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F33D3@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> PGDEV=/proc/net/pktgen/eth4

You meant :  PGDEV=/proc/net/pktgen/kpktgend_0   ???

>   echo "Configuring $PGDEV"
>  pgset "$COUNT"
>  pgset "$CLONE_SKB"
>  pgset "$PKT_SIZE"
>  pgset "$DELAY"
>  pgset "dst 10.10.11.2" 
>  pgset "queue_map_min 0"
>  pgset "queue_map_max 7"
>  pgset "dst_mac  00:04:23:08:91:dc"
> 
> ->it is ok
> 
> 
> Here is the top result, why only kpktgend_0 is running?
> Eric,can you share the pktgen script? Thank you

If you want to control several kpktgend you need to send each one of
them a full pktgen script.

PGDEV=/proc/net/pktgen/kpktgend_0
script0
PGDEV=/proc/net/pktgen/kpktgend_1
script1
PGDEV=/proc/net/pktgen/kpktgend_2
script2
PGDEV=/proc/net/pktgen/kpktgend_3
script3



