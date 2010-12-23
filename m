From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Thu, 23 Dec 2010 12:50:57 +0200
Message-ID: <f8440be16d88634c31f1e817d5b63ad9.squirrel@www.liukuma.net>
References: <e1a7dc28b8b95e93d38edc418d59e89a.squirrel@www.liukuma.net>
    <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F39C2@MILEXCH2.ds.jdsu.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Jon Zhou" <Jon.Zhou@jdsu.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:18117 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748Ab0LWKvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 05:51:04 -0500
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F249D5F39C2@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Ethtool -S "My intel x520 10G nic" will show there are 8 rx/tx queues
>
> I just made 5M pps with 64 bytes packet according to link given by eric
> Dumazet.
> (connect the 2 ports with each other of the NIC, XEON E5540,kernel
> 2.6.32,set irq affinity, Noted that I have an abnormal ksoftirqd/2 which
> occupy 30%cpu even at idle state, so the result still has space to
> improve)
>
> At another old kernel(2.6.16) with tg3 and bnx2 1G NIC,XEON E5450, I only
> got 490K pps(it is about 300Mbps,30% GE), I think the reason is multiqueue
> unsupported in this kernel.
>
> I will do a test with 1Gb nic on the new kernel later.
>

Which do you suppose is the reason for poor performance on my setup,
is it lack of multiqueue HW in the GE NIC's I am using or is it lack
of multiqueue support in the kernel (2.6.32) that I am using?

Is multiqueue really necessary to achieve the full 1GE saturation, or
is it only needed on 10GE NIC's?

As I understand multiqueue is useful only if there are lots of CPU cores
to run, each handling one queue.

The application I am thinking of, preloading a packet sequence into
kernel from userland application and then starting to send from buffer
propably does not benefit so much from many cores, it would be enough
that one CPU would handle the sending and other core(s) would handle
other tasks.

Yours, Jussi Ohenoja


