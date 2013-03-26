From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: TX Buffer incorrectly initialized
Date: Tue, 26 Mar 2013 09:08:02 -0700
Message-ID: <1364314082.1716.38.camel@edumazet-glaptop>
References: <y> <1364311507-7489-1-git-send-email-jim_baxter@mentor.com>
	 <1364312644.1716.33.camel@edumazet-glaptop> <5151C637.9010403@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:64976 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665Ab3CZQIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:08:05 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so2603985dal.40
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 09:08:04 -0700 (PDT)
In-Reply-To: <5151C637.9010403@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 16:00 +0000, Jim Baxter wrote:
> The field is the extended status control for the FEC network device, the
> values written to it are used to set the hardware transmit and receive
> state.

Hmm, I guess this driver has no intent to be endian safe then...
