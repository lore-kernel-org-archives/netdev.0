From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Thu, 13 Nov 2008 07:15:43 +0000
Message-ID: <20081113071543.GB4505@ff.dom.local>
References: <20081111214702.subn3mt7uylkiref@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:10167 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbYKMHPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 02:15:49 -0500
Received: by ik-out-1112.google.com with SMTP id c29so658683ika.5
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 23:15:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081111214702.subn3mt7uylkiref@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-11-2008 22:47, Sami Farin wrote:
...
> When 2.6.27.5 was sending:
> 
> 2008-11-11T21:16:13.488287Z IP (tos 0x0, ttl 255, id 10323, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0x96a4), 4123538094:4123545194(7100) ack 1017886112 win 710 <nop,nop,timestamp 418352 372760162>
> 2008-11-11T21:16:13.620018Z IP (tos 0x0, ttl 255, id 10328, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xf1d0), 4123545194:4123552294(7100) ack 1017886112 win 710 <nop,nop,timestamp 418458 372760270>
> 2008-11-11T21:16:13.751751Z IP (tos 0x0, ttl 255, id 10333, offset 0, flags [none], proto TCP (6), length 7152) 80.223.84.180.40449 > 74.54.226.166.80: ., cksum 0xee52 (incorrect (-> 0xc685), 4123552294:4123559394(7100) ack 1017886112 win 710 <nop,nop,timestamp 418562 372760374>
> 
> I noticed it's 7152 bytes a packet!
> Is this a new trick in 2.6.27 or 2.6.26?
> But:
> <3>[ 1583.914947] 0000:00:19.0: eth0: Jumbo Frames not supported.
> 

Could you check for TSO (and maybe turn this off) with ethtool?

Thanks,
Jarek P.
