From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCHES] TX batching
Date: Tue, 9 Oct 2007 13:44:38 +0530
Message-ID: <OF568108F3.5706A2B5-ON6525736F.002CED41-6525736F.002D492F@in.ibm.com>
References: <1191852320.4352.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, kaber@trash.net,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	randy.dunlap@oracle.com, rdreier@cisco.com, rick.jones2@hp.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP05.au.ibm.com ([202.81.18.174]:57373 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbXJIIPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 04:15:05 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l998F3Dj015679
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 18:15:03 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l998G5RI238434
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 18:16:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l998CS4W010330
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 18:12:31 +1000
In-Reply-To: <1191852320.4352.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J Hadi Salim <j.hadi123@gmail.com> wrote on 10/08/2007 07:35:20 PM:

> I dont see something from Krishna's approach that i can take and reuse.
> This maybe because my old approaches have evolved from the same path.
> There is a long list but as a sample: i used to do a lot more work while
> holding the queue lock which i have now moved post queue lock; i dont
> have any speacial interfaces/tricks just for batching, i provide hints
> to the core of how much the driver can take etc etc. I have offered
> Krishna co-authorship if he makes the IPOIB driver to work on my
> patches, that offer still stands if he chooses to take it.

My feeling is that since the approaches are very different, it would
be a good idea to test the two for performance. Do you mind me doing
that? Ofcourse others and/or you are more than welcome to do the same.

I had sent a note to you yesterday about this, please let me know
either way.

******************* Previous mail ******************

Hi Jamal,

If you don't mind, I am trying to run your approach vs mine to get some
results
for comparison.

For starters, I am having issues with iperf when using your infrastructure
code with
my IPoIB driver - about 100MB is sent and then everything stops for some
reason.
The changes in the IPoIB driver that I made to support batching is to set
BTX, set
xmit_win, and dynamically reduce xmit_win on every xmit and increase
xmit_win on
every xmit completion. Is there anything else that is required from the
driver?

thanks,

- KK

