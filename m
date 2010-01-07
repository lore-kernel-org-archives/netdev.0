From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH] via-velocity: add netpoll functionality for the benefit
 of netconsole
Date: Thu, 7 Jan 2010 07:26:16 +0100
Message-ID: <20100107072616.4fe2bfb7@marrow.netinsight.se>
References: <4B423440.6060807@computer.org>
	<20100105072800.13dba6d2@marrow.netinsight.se>
	<4B439ED5.0@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?St=E9phane?= Berthelot <sberthelot@emisfr.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:12521 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751520Ab0AGG00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 01:26:26 -0500
In-Reply-To: <4B439ED5.0@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jan 2010 21:19:33 +0100
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> Simon Kagstrom wrote:
> > Does the patch still work with the new NAPI support in the driver?
> 
> Errr. (Is my ignorance showing yet?)
> 
> I will have to study this, based on other drivers and your commit dfff71.

Well, if you have tested it and netconsole works with the new driver I
would guess it's OK. I don't know netconsole myself, but I know the
interrupt handler (which you call from your patch) has changed with the
NAPI support, so that's why I was wondering if it still worked.

// Simon
