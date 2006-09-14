From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] natsemi: Messages being noisy
Date: Thu, 14 Sep 2006 17:39:08 +0200
Message-ID: <200609141739.08461.netdev@axxeo.de>
References: <200609131528.51336.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:28296 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750850AbWINPjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 11:39:15 -0400
To: Tim Hockin <thockin@hockin.org>
In-Reply-To: <200609131528.51336.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

Ingo Oeser wrote:
> I  get the following message when trying to transfer big files 
> (via FTP or SCP) since Linux 2.6.16.27. It didn't happen with Linux 2.6.13.4.
> 
> [702238.242237] eth1: increased tx threshold, txcfg 0xd0f01008.
> [702238.242649] eth1: increased tx threshold, txcfg 0xd0f0100a.
> 
> What about putting this message at the message level "DEBUG"
> or even under pr_debug()?

Now I even know, that this happens together with a small disruption 
of traffic, which makes applications hang for a second or less.

Is it possible to have the maximum value right from the start?
May I tune it somewhere to be the maximum from the start?

Would you accept patches for this?

Regards

Ingo Oeser
