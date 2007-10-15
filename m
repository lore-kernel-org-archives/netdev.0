From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 18:05:12 +0200
Message-ID: <20071015160512.GA15178@one.firstfloor.org>
References: <1192038559.29746.127.camel@eliezer> <p73641c4cfz.fsf@bingen.suse.de> <20071012.150341.41635825.davem@davemloft.net> <1192462049.29746.158.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, jeff@garzik.org, mchan@broadcom.com
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38433 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759248AbXJOQFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 12:05:14 -0400
Content-Disposition: inline
In-Reply-To: <1192462049.29746.158.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is not a driver issue.
> Unfortunately, the firmware code is different for LE and BE machines.
> We had issues with the BE firmware that appear to be resolved.
> Hopefully, the next version will have both.

If the firmware is big it might be better to just add the necessary
conversions to the driver and always use BE. Endian conversions
tend to be very cheap.

Also we probably should have BE/LE Kconfig symbol for this to handle such
cases more elegantly in the future.

-Andi
