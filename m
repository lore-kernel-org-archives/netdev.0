From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 1/3] [NET_BATCH] Introduce batching interface
Date: Mon, 8 Oct 2007 15:29:02 +0530
Message-ID: <OF821E811C.0B4972CE-ON6525736E.0035FA06-6525736E.0036D812@in.ibm.com>
References: <1191782183.4394.62.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:41584 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbXJHKBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 06:01:14 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l98A14Hj018036
	for <netdev@vger.kernel.org>; Mon, 8 Oct 2007 20:01:04 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l98A0rRX249390
	for <netdev@vger.kernel.org>; Mon, 8 Oct 2007 20:00:53 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l989vHO1003657
	for <netdev@vger.kernel.org>; Mon, 8 Oct 2007 19:57:19 +1000
In-Reply-To: <1191782183.4394.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

J Hadi Salim <j.hadi123@gmail.com> wrote on 10/08/2007 12:06:23 AM:

> This patch introduces the netdevice interface for batching.
>
> cheers,
> jamal
>
>
> [attachment "oct07-p1of3" deleted by Krishna Kumar2/India/IBM]

