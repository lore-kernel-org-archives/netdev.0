From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 11:51:22 +0300
Message-ID: <200908311151.22607.denys@visp.net.lb>
References: <20090831053026.GA5005@ff.dom.local> <200908311118.43024.denys@visp.net.lb> <20090831.013738.127727614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54272 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbZHaIz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:55:57 -0400
In-Reply-To: <20090831.013738.127727614.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 August 2009 11:37:38 David Miller wrote:
> From: Denys Fedoryschenko <denys@visp.net.lb>
> Date: Mon, 31 Aug 2009 11:18:42 +0300
>
> > 2.6.31-rc8 i got dmesg flooded. First message appearing even without
> > patch, i will make sure now what is a reason of that (i have HTB classes
> > on ifb0, and TBF on pppX).
> >
> > [  155.199923] Attempt to kill tasklet from interrupt
>
> We know the reasons for this message, it's an HTB regression and we're
> working on it.

Well, those TBF warning seems works fine, i even found one missing shaper that 
was overflowing. Thanks to Jarek.
For now no false positives. Message is appearing only when real overflow 
happen.
