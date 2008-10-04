From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: deadlock during net device unregistration - V2
Date: Sat, 4 Oct 2008 09:52:33 +0200
Message-ID: <20081004075233.GB2536@ami.dom.local>
References: <20081001.031243.255655293.davem@davemloft.net> <20081001141432.470106980@theryb.frec.bull.fr> <20081001194825.GA2520@ami.dom.local> <48E3E64E.50106@fr.ibm.com> <20081001233152.GA2411@ami.dom.local> <48E4E772.2020208@bull.net> <20081002183819.GA2664@ami.dom.local> <20081002215502.q9and4a6kg4cs0o8@intran0x.frec.bull.fr> <20081002203435.GC2664@ami.dom.local> <20081004074248.GA2536@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Benjamin Thery <Benjamin.Thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:22969 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbYJDHwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 03:52:06 -0400
Received: by ey-out-2122.google.com with SMTP id 6so640417eyi.37
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 00:52:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081004074248.GA2536@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 04, 2008 at 09:42:48AM +0200, Jarek Poplawski wrote:
...
> During this all other works would be unnecessarily blocked by the
> linkwatch, what looks a bit too hoggish.

Or even more: can't some of these blockeds task hold our refs too?

Jarek P.
