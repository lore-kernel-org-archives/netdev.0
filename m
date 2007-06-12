From: Patrick McHardy <kaber@trash.net>
Subject: Re: pmtu discovery on sa esp
Date: Tue, 12 Jun 2007 14:34:44 +0200
Message-ID: <466E92E4.4020008@trash.net>
References: <BAY103-DAV17DFF0DD3E0AEE8CCCB1F3B2190@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35036 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927AbXFLMhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 08:37:35 -0400
In-Reply-To: <BAY103-DAV17DFF0DD3E0AEE8CCCB1F3B2190@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:
> Hello everybody.
> I have just upgraded from 2.6.21.3 to
> 2.6.22-rc4 and I get a ton of
> pmtu discovery on sa esp/blablab/blabla
> messages (this box is running openswan).
> Is this an expected behaviour?


We have some MTU opimiztations in 2.6.22-rc that might be related.
Please check with tcpdump what exactly is happening and whether
the 2.6.22-rc box is sending too large packets.
