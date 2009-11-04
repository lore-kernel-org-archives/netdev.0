From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 4 Nov 2009 13:39:59 +0000
Message-ID: <20091104133959.GB8578@ff.dom.local>
References: <4AF1660E.1080401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ryousei Takano <ryousei@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:43570 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210AbZKDNkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:40:00 -0500
Received: by bwz27 with SMTP id 27so8871824bwz.21
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 05:40:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AF1660E.1080401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-11-2009 12:31, Eric Dumazet wrote:
....
> Maybe you can try changing class mtu to 40000 instead of 9000, and quantum to 60000 too
> 
> tc class add dev $DEV parent 1: classid 1:1 htb rate ${rate}mbit mtu 40000 quantum 60000
> 
> (because your tcp stack sends large buffers ( ~ 60000 bytes) as your NIC can offload tcp segmentation)
> 

Hmm..., testing htb scheduling exactness with tso/gso on seems kind of
weather reporting. On the other hand, depending on hardware, these
rates could be available with mtu 9000 and tso/gso off, unless I
miss something. So maybe such a test would be interesting too?
Then I'd suggest this one, erlier mentioned, patch to iproute2:
http://marc.info/?l=linux-netdev&m=124453482324409&w=2

Best regards,
Jarek P.
