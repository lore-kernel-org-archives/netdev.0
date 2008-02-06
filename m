From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Wed, 6 Feb 2008 15:43:25 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:44794 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbYBFOnh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 09:43:37 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unable to handle kernel paging request at ffffc200000fb000 RIP: 
>  [<ffffffff8031b8f0>] deflate_slow+0x40/0x400

Here is some more information about the scenario in which I can easily
reproduce the oops now:

Net_A - GW_A --- GW_B - Net_B

The Net_A - Net_B ESP/AES/IPComp tunnel works fine, the tunnel between
Net_B and the external IP address of GW_A triggers the oops in GW_A.

Daniel
