From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.29-rc] usbnet: allow type check of devdbg arguments
 in non-debug build
Date: Mon, 19 Jan 2009 20:08:02 -0800 (PST)
Message-ID: <20090119.200802.48047345.davem@davemloft.net>
References: <20090119.171200.235073814.davem@davemloft.net>
	<20090119.175730.262402885.davem@davemloft.net>
	<200901191804.09004.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	ian.saturley@smsc.com, jeff@garzik.org, jussi.kivilinna@mbnet.fi
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753695AbZATEIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 23:08:01 -0500
In-Reply-To: <200901191804.09004.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Mon, 19 Jan 2009 18:04:08 -0800

> Maybe, but that's after all part of why we want this kind
> of patch merged ... after the first gremlines are fixed!

When you submit a change like this that can have
potential warning and build failure effects across
the entire tree, the onus is on you to do an
allmodconfig sanity check build or similar and
add any necessary fixes to your change.
