From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU < 1280
Date: Wed, 27 Aug 2014 22:57:37 +0200
Message-ID: <CAPh34me9QwodcngH5oeH57PM1vyXuKks9wgsGcOB99RoEePVng@mail.gmail.com>
References: <53F39E50.1020209@gont.com.ar>
	<1409005545-24910-2-git-send-email-hagen@jauu.net>
	<1409006842.6274.69.camel@localhost>
	<53FE4086.8040708@si6networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: Fernando Gont <fgont@si6networks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:40647 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbaH0U5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:57:39 -0400
Received: by mail-la0-f41.google.com with SMTP id gi9so70518lab.0
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 13:57:38 -0700 (PDT)
In-Reply-To: <53FE4086.8040708@si6networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 August 2014 22:33, Fernando Gont <fgont@si6networks.com> wrote:

> Hence the trivial way to mitigate this attack is to drop incoming ICMPv6
> PTB1280 (or, at the very least, don't react to them by sending all
> subsequent packets with a Fragment Header).

Any news from the v6ops people - what is your suggestion Fernando?
Should we wait for more v6ops input?

Hagen
