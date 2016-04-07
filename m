From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V3 05/16] net: fec: reduce interrupts
Date: Thu, 7 Apr 2016 08:50:53 -0700
Message-ID: <570681DD.5020208@boundarydevices.com>
References: <1459909562-22865-6-git-send-email-troy.kisky@boundarydevices.com>
 <20160406.172008.266926707628676037.davem@davemloft.net>
 <5705AD07.10009@boundarydevices.com>
 <20160406.235731.57253886354009409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33936 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756552AbcDGPu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:50:56 -0400
Received: by mail-pf0-f172.google.com with SMTP id c20so58152882pfc.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:50:55 -0700 (PDT)
In-Reply-To: <20160406.235731.57253886354009409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2016 8:57 PM, David Miller wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com>
> Date: Wed, 6 Apr 2016 17:42:47 -0700
> 
>> Sure, that's an easy change. But if a TX int is what caused the
>> interrupt and masks them, and then a RX packet happens before napi
>> runs, do you want the TX serviced 1st, or RX ?
> 
> If you properly split your driver up into seperate interrupt/poll
> instances, one for TX one for RX, you wouldn't need to ask me
> that question now would you?
> 
> :-)
> 

I absolutely claim no ownership :-)
