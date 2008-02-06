From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Wed, 6 Feb 2008 21:55:03 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:48755 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757502AbYBFUzK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 15:55:10 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080206170717.GA20308@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Net_A - GW_A --- GW_B - Net_B
>> The Net_A - Net_B ESP/AES/IPComp tunnel works fine, the tunnel
between
>> Net_B and the external IP address of GW_A triggers the oops in GW_A.

> That's interesting.  So which one out of A and B is running 2.6.24?

A is the oopsing 2.6.24, B is 2.6.23.
I didn't change anything in the scenario recently, till 2.6.23 all
worked fine.

Daniel
