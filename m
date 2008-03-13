From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: MACB driver question
Date: Thu, 13 Mar 2008 01:12:37 +0100
Message-ID: <20080313011237.3119f8e8@siona.local>
References: <d6c8ef150803120804qfd2f57ds509ddf40c5ddbb11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Bosko Radivojevic" <bosko.radivojevic@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:59353 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755389AbYCMAMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 20:12:03 -0400
In-Reply-To: <d6c8ef150803120804qfd2f57ds509ddf40c5ddbb11@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2008 16:04:27 +0100
"Bosko Radivojevic" <bosko.radivojevic@gmail.com> wrote:

> Hi Haavard!
> 
> I have question regarding MACB driver. Actually, I want to use it
> without connected PHY (we connected MACB directly to EtherCAT ET1200
> asic). In previous versions (2.6.20) I've manually removed all
> phy-related parts from macb.c at it works good. Now, when there is PHY
> API is there any 'nice and clean' way for doing it? I've tried with
> Fixed PHY, but it is not working (I get "No PHY found" message). For
> the test purposes, I tried the same with another board with Micrel's
> PHY and it works (with Fixed PHY, 100/Full).

Sorry, I don't have much experience with the Fixed PHY driver, but I
was under the impression that this is the sort of thing it was meant
for. Maybe someone at the Netdev list can help?

(dropping linux-arm from Cc becase it's subscribers-only and it was the
wrong list to begin with.)

Haavard
