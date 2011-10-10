From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Mon, 10 Oct 2011 18:38:55 +0200
Message-ID: <4E931F9F.3040307@hartkopp.net>
References: <4E8C78E8.3010605@hartkopp.net>	<20111005155127.GB13794@pengutronix.de>	<4E8C8175.2040202@hartkopp.net>	<4E8D528D.8020607@hartkopp.net>	<4E8D7065.8040905@grandegger.com>	<4E8DBC34.80607@hartkopp.net> <CAOCMmufQ77Vz4XTSTZTVSMiOA4QtWkZEvWHjGXip5-JK20E=QA@mail.gmail.com> <4E8DF24E.5030606@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andre Naujoks <nautsch@gmail.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:49904 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220Ab1JJQjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:39:19 -0400
In-Reply-To: <4E8DF24E.5030606@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/11 20:24, Wolfgang Grandegger wrote:


> Well, copying just the relevant bytes seem much more straight-forward
> than removing accidentally copied bytes later-on. You do not need to
> care about little endian. The MSCAN is only available on PowerPC SOCs,
> which are big endian.
> 
> I'm going to test and post a patch tomorrow.


Thanks.

My patch is then superseded by this one

"mscan: too much data copied to CAN frame due to 16 bit accesses"

http://patchwork.ozlabs.org/patch/118364/

Tnx,
Oliver
