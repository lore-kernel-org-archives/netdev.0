From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Tue, 26 Mar 2013 23:04:17 +0100
Message-ID: <1364335457.8215.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:53116 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab3CZWL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 18:11:56 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.baanhofman.nl (Postfix) with ESMTP id 71703788C3
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 23:04:18 +0100 (CET)
Received: from mail.baanhofman.nl ([127.0.0.1])
	by localhost (blackhole.synnack.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id V1l4oXZmcwLK for <netdev@vger.kernel.org>;
	Tue, 26 Mar 2013 23:04:06 +0100 (CET)
Received: from [IPv6:2001:470:d1e7:1337:6cff:5d60:f81e:c34] (unknown [IPv6:2001:470:d1e7:1337:6cff:5d60:f81e:c34])
	by mail.baanhofman.nl (Postfix) with ESMTPSA id B0133788BC
	for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 23:04:06 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was trying to get OSPFv3 working on NBMA 6in4 tunnel on linux 3.8, but
it does not work. I noticed it uses a /128 fe80 link-local subnet
instead of the rfc4213[1]-mandated /64.. This breaks bird (likely for
other reasons), but also interoperability with cisco, which mandates
OSPFv3 NBMA on link-local addresses.

So I was wondering, is there any particular reason for the use of a /128
link-local or is this just a bug?

Regards,

Wilco Baan Hofman


[1] http://tools.ietf.org/html/rfc4213
