From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 18 Jun 2007 11:16:10 -0400
Message-ID: <1182179770.4063.26.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
	 <1182129521.4092.77.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:43237 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196AbXFRPQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 11:16:13 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1534653wxc
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 08:16:12 -0700 (PDT)
In-Reply-To: <1182129521.4092.77.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Yi,

On Mon, 2007-18-06 at 09:18 +0800, Zhu Yi wrote:

> Would you respond the question I asked early, 

I thought i did respond to all questions you asked but some may have
been lost in the noise. 

> in your model how to
> define the queue wakeup strategy in the driver to deal with the PHL full
> situation? Consider about 1) both high prio and low prio packets could
> come (you cannot predict it beforehand) 

I am assuming by "come" you mean from the stack (example an ssh packet)
as opposed from the outside.

> 2) the time for PHL to send out
> a packet to the wireless medium is relative long (given the medium is
> congested). If you can resolve it in an elegant way, I'm all ears.

Congestion periods are the only time any of this stuff makes sense.
Ok, so let me repeat what i said earlier:

Once a packet is in the DMA ring, we dont take it out. If a high prio
packet is blocking a low prio one, i consider that to be fine. If otoh,
you receive a management detail from the AP indicating that LP has its
priority bumped or HP has its prio lowered, then by all means use that
info to open up the path again. Again, that is an example, you could use
that or schemes (refer to my expression on cats earlier).

Anyways, you will have to forgive me - this thread is getting too long
and i dont have much time to follow up on this topic for about a week;
and given we are not meeting anywhere in the middle i am having a hard
time continuing to repeat the same arguements over and over again. It is
ok for rational people to agree to disagree for the sake of progress

cheers,
jamal

