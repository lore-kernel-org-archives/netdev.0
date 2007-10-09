From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCHES] TX batching
Date: Tue, 09 Oct 2007 09:25:42 -0400
Message-ID: <1191936342.4373.187.camel@localhost>
References: <OF568108F3.5706A2B5-ON6525736F.002CED41-6525736F.002D492F@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, kaber@trash.net,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	randy.dunlap@oracle.com, rdreier@cisco.com, rick.jones2@hp.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:41265 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbXJINZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 09:25:50 -0400
Received: by el-out-1112.google.com with SMTP id v27so304039ele
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 06:25:48 -0700 (PDT)
In-Reply-To: <OF568108F3.5706A2B5-ON6525736F.002CED41-6525736F.002D492F@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-10 at 13:44 +0530, Krishna Kumar2 wrote:

> My feeling is that since the approaches are very different, 

My concern is the approaches are different only for short periods of
time. For example, I do requeueing, have xmit_win, have ->end_xmit,
do batching from core etc; if you see value in any of these concepts,
they will appear in your patches and this goes on a loop. Perhaps what
we need is a referee and use our energies in something more positive.

> it would be a good idea to test the two for performance. 

Which i dont mind as long as it has an analysis that goes with it.
If all you post is "heres what netperf showed", it is not useful at all.
There are also a lot of affecting variables. For example, is the
receiver a bottleneck? To make it worse, I could demonstrate to you that
if i slowed down the driver and allowed more packets to queue up on the
qdisc, batching will do well. In the past my feeling is you glossed over
such details and i am sucker for things like that - hence the conflict.

> Do you mind me doing
> that? Ofcourse others and/or you are more than welcome to do the same.
> 
> I had sent a note to you yesterday about this, please let me know
> either way.
> 

I responded to you - but it may have been lost in the noise; heres a
copy:
http://marc.info/?l=linux-netdev&m=119185137124008&w=2

cheers,
jamal

