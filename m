From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink & bonding: change args got
 get_tx_queues
Date: Wed, 11 Apr 2012 07:55:47 +0200
Message-ID: <1334123747.5300.2197.camel@edumazet-glaptop>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
	 <1334009344.7150.268.camel@deadeye>
	 <20120410213443.31fc0784@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53762 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab2DKFzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 01:55:52 -0400
Received: by wgbdr13 with SMTP id dr13so533484wgb.1
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 22:55:50 -0700 (PDT)
In-Reply-To: <20120410213443.31fc0784@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 21:34 -0700, Stephen Hemminger wrote:
> Change get_tx_queues, drop unsused arg/return value real_tx_queues,
> and use return by value (with error) rather than call by reference.
> 
> Probably bonding should just change to LLTX and the whole get_tx_queues
> API could disappear!

Absolutely ;)
