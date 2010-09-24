From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: bonding vs GSO vs checksumming.
Date: Thu, 23 Sep 2010 17:56:43 -0700
Message-ID: <AANLkTim2FF2n9JXfpdZmmnV5ZJ1ptC7se_JiU_z91okt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35671 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab0IXA4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 20:56:45 -0400
Received: by wyb28 with SMTP id 28so1462285wyb.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 17:56:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing the following:

bonding: caps=(0x1113a3, 0x1113ab) len=18192 data_len=18120 ip_summed=0

on a 2.6.34.5 based kernel originating from v6 tcp transmit (mtu 1280)
on a bonded device of tg3 (presumably with TSO6) and forcedeth
(presumably without TSO6).

I can't quite figure out what this truly means...

Help ;-)
