From: "SANGTAE HA" <sangtae.ha@gmail.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 19:17:20 -0500
Message-ID: <649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
	 <20080130.055333.192844925.davem@davemloft.net>
	 <Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
	 <20080130082136.1017631d@deepthought>
	 <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Bruce Allen" <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:42687 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338AbYAaARX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 19:17:23 -0500
Received: by wr-out-0506.google.com with SMTP id c48so527034wra.23
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 16:17:22 -0800 (PST)
In-Reply-To: <Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bruce,

On Jan 30, 2008 5:25 PM, Bruce Allen <ballen@gravity.phys.uwm.edu> wrote:
>
> In our application (cluster computing) we use a very tightly coupled
> high-speed low-latency network.  There is no 'wide area traffic'.  So it's
> hard for me to understand why any networking components or software layers
> should take more than milliseconds to ramp up or back off in speed.
> Perhaps we should be asking for a TCP congestion avoidance algorithm which
> is designed for a data center environment where there are very few hops
> and typical packet delivery times are tens or hundreds of microseconds.
> It's very different than delivering data thousands of km across a WAN.
>

If your network latency is low, regardless of type of protocols should
give you more than 900Mbps. I can guess the RTT of two machines is
less than 4ms in your case and I remember the throughputs of all
high-speed protocols (including tcp-reno) were more than 900Mbps with
4ms RTT. So, my question which kernel version did you use with your
broadcomm NIC and got more than 900Mbps?

I have two machines connected by a gig switch and I can see what
happens in my environment. Could you post what parameters did you use
for netperf testing?
and also if you set any parameters for your testing, please post them
here so that I can see that happens to me as well.

Regards,
Sangtae
