From: jamal <hadi@cyberus.ca>
Subject: Re: Re: pktgen terminating condition
Date: Fri, 31 Aug 2007 09:50:03 -0400
Message-ID: <1188568203.4302.22.camel@localhost>
References: <1188562644-ab74f9e250635783bce7d5179bcd17eb@brownhat.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mandeep Baines <mandeep.baines@gmail.com>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:41586 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965021AbXHaNuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 09:50:11 -0400
Received: by nz-out-0506.google.com with SMTP id s18so615127nze
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 06:50:10 -0700 (PDT)
In-Reply-To: <1188562644-ab74f9e250635783bce7d5179bcd17eb@brownhat.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-31-08 at 14:17 +0200, Daniele Venzano wrote:

> I don't regard the TxOK solution as something usable for mainline, but it has its 
> use for the users of pktgen.

I dont know if you followed the discussion - by defering the freeing of
skbs, you will be slowing down socket apps sending from the local
machine. It may be ok if the socket buffers were huge, but that comes at
the cost of system memory (which may not be a big deal)
Do you by any chance recall why you used the idle interupt instead of
txok to kick the prunning of tx descriptors?

cheers,
jamal

