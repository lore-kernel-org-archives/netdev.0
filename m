From: "David S. Miller" <davem@redhat.com>
Subject: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: 18 May 2003 20:01:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053313298.3909.5.camel@rth.ninka.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GEIn1Y6uCsLvcyGp3lfQ"
Cc: netdev@oss.sgi.com, sommere@ethanet.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-GEIn1Y6uCsLvcyGp3lfQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I'm forwarding Ethan's announcement here.  Ethan, you'll get
better reception to your ideas if you post them to the correct
place.  Most networking hackers do not read linux-kernel due to
the sheer volume of traffic there :-)

-- 
David S. Miller <davem@redhat.com>

--=-GEIn1Y6uCsLvcyGp3lfQ
Content-Disposition: inline
Content-Description: Forwarded message - [ANNOUNCE] Layer-7 Filter for
	Linux QoS
Content-Type: message/rfc822

Return-Path: <linux-kernel-owner+davem=40rth.ninka.net@vger.kernel.org>
Received: from vger.kernel.org (vger.kernel.org [209.116.70.75]) by
	rth.ninka.net (8.12.8/8.12.8) with ESMTP id h4J2QDQH004381 for
	<davem@rth.ninka.net>; Sun, 18 May 2003 19:26:16 -0700
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand id
	S262306AbTESCKg (ORCPT <rfc822;davem@rth.ninka.net>); Sun, 18 May 2003
	22:10:36 -0400
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S262307AbTESCKf
	(ORCPT <rfc822;linux-kernel-outgoing>); Sun, 18 May 2003 22:10:35 -0400
Received: from Kona.Carleton.edu ([137.22.93.220]:29371 "EHLO
	kona.carleton.edu") by vger.kernel.org with ESMTP id S262306AbTESCKe (ORCPT
	<rfc822;linux-kernel@vger.kernel.org>); Sun, 18 May 2003 22:10:34 -0400
Received: from ethanet.com (pcSommerE.Res.Carleton.edu [137.22.99.222]) by
	carleton.edu (PMDF V6.2 #30648) with ESMTPA id
	<0HF4003313Z6NS@carleton.edu> for linux-kernel@vger.kernel.org; Sun, 18 May
	2003 21:23:30 -0500 (CDT)
Date: Sun, 18 May 2003 21:23:45 -0500
From: Ethan Sommer <sommere@ethanet.com>
Subject: [ANNOUNCE] Layer-7 Filter for Linux QoS
To: linux-kernel@vger.kernel.org
Message-id: <3EC84031.90300@ethanet.com>
MIME-version: 1.0
Content-type: text/plain; format=flowed; charset=us-ascii
Content-transfer-encoding: 7bit
X-Accept-Language: en-us, en
User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4b) Gecko/20030515
	Thunderbird/0.1a
Sender: linux-kernel-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-kernel@vger.kernel.org

We have written a filter for the QoS infrastructure that looks at the 
data segment of packets and uses regular expressions to identify the 
protocol of a stream of traffic regardless of port number.

Many peer-to-peer programs (such as Kazaa and Gnucleus) will change to 
use a different port (including well known ports such as, say, 80) if 
they find that they can get better throughput there. That means that the 
port based filtering is no longer sufficient. However, by analyzing the 
application layer data, we can differentiate Kazaa from non-Kazaa HTTP, 
and lower the priority of whichever we deem to be less important. :)

It is a filter in the existing QoS infrastructure, so it can be used in 
conjunction with u32 filters, HTB or CBQ scheduling, SFQ queueing etc, 
etc...

Commercial companies sell devices which do layer-7 classification for 
anywhere from $6000-$80,000 depending on the bandwidth required. If we 
can build a comprehensive set of patterns I don't see any reason why 
Linux can't beat the pants off the commercial devices; we already have 
excellent queueing, and scheduling.

Our home page is http://l7-filter.sourceforge.net/ but if you want to 
skip right to the downloads go to 
http://sourceforge.net/projects/l7-filter/ (there is a kernel patch, a 
patched version of tc, and some sample patterns for HTTP, POP3, IMAP, 
SSH, Kazaa, and FTP.) You'll notice the patch is a somewhat large, most 
of that is regexp code.

We're still working on it. It currently only does TCP for example... Do 
you guys/gals have any comments/suggestions/etc? I suspect that this is 
a post 2.6 thing, but it is very non-invasive (it only adds approx. 2 
lines of code that would affect anything if the user were not using the 
layer-7 filters,) so I still have a little bit of hope.

Ethan Sommer
Matt Strait
Justin Levandoski

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--=-GEIn1Y6uCsLvcyGp3lfQ--
