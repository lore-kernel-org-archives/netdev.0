From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Tue, 22 Dec 2015 16:15:14 +0100
Message-ID: <56796902.8080703@stressinduktion.org>
References: <20151212195830.GA18286@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36560 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298AbbLVPPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 10:15:16 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 14BC020C86
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 10:15:16 -0500 (EST)
In-Reply-To: <20151212195830.GA18286@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.12.2015 20:58, Marc Haber wrote:
> Any hints would be appreciated.

This sysctl should help:

accept_ra_from_local - BOOLEAN
        Accept RA with source-address that is found on local machine
        if the RA is otherwise proper and able to be accepted.
        Default is to NOT accept these as it may be an un-intended
        network loop.

        Functional default:
           enabled if accept_ra_from_local is enabled
               on a specific interface.
           disabled if accept_ra_from_local is disabled
               on a specific interface.

Anyway, this has to be fixed up in a clean way and should work by default.

Thanks for the report,
Hannes
