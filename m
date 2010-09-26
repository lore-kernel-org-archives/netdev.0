From: David Miller <davem@davemloft.net>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 16:08:38 -0700 (PDT)
Message-ID: <20100926.160838.246540910.davem@davemloft.net>
References: <20100926223448.GF12373@1wt.eu>
	<20100926.153832.115943505.davem@davemloft.net>
	<20100926225440.GH12373@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57406
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757592Ab0IZXIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 19:08:18 -0400
In-Reply-To: <20100926225440.GH12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Mon, 27 Sep 2010 00:54:40 +0200

> On Sun, Sep 26, 2010 at 03:38:32PM -0700, David Miller wrote:
>> From: Willy Tarreau <w@1wt.eu>
>> Date: Mon, 27 Sep 2010 00:34:48 +0200
>> 
>> > I don't see what is being violated nor what reliability has been
>> > compromised.
>> 
>> The TCP protcol's obligation to reliably deliver data between
>> two applications, that is what has been violated.
> 
> Once again, I don't see why, due to the orphans mechanism. Please
> consider for a minute that the application-level close() is distinct
> from the protocol-level close. The application-level close() just
> instructs the lower layer to turn the connection into an orphan.

A close() is equivalent to a shutdown() with both the send and
receive masks set.

You are telling TCP that you expect no more data to be received.
