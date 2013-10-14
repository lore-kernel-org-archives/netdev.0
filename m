From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHSET v1 00/07] Support for byte queue limits on various
 network interfaces
Date: Mon, 14 Oct 2013 11:41:17 -0700
Message-ID: <20131014114117.5808e665@nehalam.linuxnetplumber.net>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:55185 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755590Ab3JNSlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 14:41:21 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so7637604pbb.38
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 11:41:21 -0700 (PDT)
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Oct 2013 20:26:16 +0200
Tino Reichardt <milky-kernel@mcmilk.de> wrote:

> Hello,
> 
> this patchset adds support for byte queue limits for various network drivers.
> 
> These drivers are used as WAN interface on servers that I am managing. So
> it would be nice, if support for BQL / codel for these drivers will make it
> into the mainline... @ some time ;)
> 
> 
> Any comments are welcome, thanks.
> Tino Reichardt

How many of these have been tested on real devices?
BQL has a nasty way of exposing bugs.
