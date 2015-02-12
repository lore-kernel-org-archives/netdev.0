From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Wed, 11 Feb 2015 20:06:14 -0800
Message-ID: <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150212005844.GB3829@nwwn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Marshall <tom@cyngn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:44572 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbBLEGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 23:06:16 -0500
Received: by mail-qg0-f42.google.com with SMTP id z107so6232972qgd.1
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 20:06:15 -0800 (PST)
In-Reply-To: <20150212005844.GB3829@nwwn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-11 at 16:58 -0800, Tom Marshall wrote:
> Port zero is reserved according to IANA.
> 
> Note UDP sendto is already disallowed if dport is zero.

I have no idea why we should prevent such thing.

There is nothing wrong sending a TCP frame with dport=0, even if
practically it is not possible to setup a listener on such port using
BSD API.

Maybe some tools are actually using this already to send probes...
