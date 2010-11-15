From: David Miller <davem@davemloft.net>
Subject: vmxnet3 multiqueue
Date: Mon, 15 Nov 2010 10:16:49 -0800 (PST)
Message-ID: <20101115.101649.245385009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932974Ab0KOSQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:16:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two things:

1) Do not quote the entire patch when asking for feedback,
   that adds needless scrolling for people trying to read
   through either the thread on an archive site or me trying
   to skim through the feedback in the patchwork entry.

   You are not adding any new information at all by quoting
   the entire patch, and in fact you are making it more difficult
   for the very people you want replies from.

2) You're still adding driver specific module option knobs
   which we have consistently stated are not to be added to
   any driver.  Instead create generic facilities that any
   driver, not just your's, can make use of.

For now I would simply rip out the module option knobs and
submit the simplest patch possible which always turns on
multiqueue and never acts conditionally.

You can add the knobs via a kernel wide facility later.
