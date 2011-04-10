From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Sun, 10 Apr 2011 11:49:50 -0700
Message-ID: <20110410114950.0283f0c5@nehalam>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37474 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754970Ab1DJSt6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 14:49:58 -0400
In-Reply-To: <20110410131321.8CD9713A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> Caveats:
>  - driver modifies vlan_features on HW VLAN TX changes
>  - broken RX checksum will be reenabled on features change

This seems unsafe.
