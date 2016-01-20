From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Tools for sampling ethtool --statistics
Date: Wed, 20 Jan 2016 14:53:02 -0800
Message-ID: <56A00FCE.5010907@gmail.com>
References: <20160120101311.5266cac6@redhat.com> <CAJ3xEMiNDU20FVG_9_r11wqMmAFiERBTYcsFmjwaSfbZ25NOiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34320 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbcATWxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 17:53:16 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so12311017pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 14:53:15 -0800 (PST)
In-Reply-To: <CAJ3xEMiNDU20FVG_9_r11wqMmAFiERBTYcsFmjwaSfbZ25NOiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> 
>> pktgen (4 cores) sending ~50Mpps
> [...]
> 
> The 20M for single ring/core and 50M pps for four streams are really
> cool results. Do the scripts to get ~such results exist in your
> network testing github repo? last time I looked I wasn't sure if  the
> multi-stream case is supported.
> 
> Could you post the two commands you used for these results along with
> minimal spec of the system (CPU type/freq, special .config directives,
> anything else)?
> 

Take a look at

./samples/pktgen/pktgen_sample02_multiqueue.sh
./samples/pktgen/pktgen_sample03_burst_single_flow.sh

that should get you there.

.John

> Or.
