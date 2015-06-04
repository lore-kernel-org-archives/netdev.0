From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 0/6] net: Identifier Locator Addressing
Date: Thu, 4 Jun 2015 11:00:13 +0200
Message-ID: <20150604090013.GB20040@pox.localdomain>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, agartrell@fb.com, maheshb@google.com,
	netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36926 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbbFDJAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 05:00:17 -0400
Received: by wifw1 with SMTP id w1so50631239wif.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 02:00:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/15 at 12:58pm, Tom Herbert wrote:
> The data path for ILA is a simple NAT translation that only operates
> on the upper 64 bits of a destination address in IPv6 packets. The
> basic process is:
> 
>    1) Lookup 64 bit identifier (lower 64 bits of destination) in a table
>    2) If a match is found
>       a) Overwrite locator (upper 64 bits of destination) with
>          new locator
>       b) Adjust any checksum that has destination address included in
>          pseudo header
>    3) Send or receive packet

Nice. I like this a lot!
