From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: code cleanups
Date: Fri, 01 Jul 2011 17:46:15 -0700 (PDT)
Message-ID: <20110701.174615.1986418433247529596.davem@davemloft.net>
References: <1309510843.10177.10.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, joe@perches.com, sebastian.poehn@belden.com
To: sebastian.belden@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab1GBAqW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 20:46:22 -0400
In-Reply-To: <1309510843.10177.10.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
Date: Fri, 01 Jul 2011 11:00:43 +0200

> # moves if_vlan.h include from gianfar.c to gianfar.h

Please don't do this, keep the explicit includes as close
to the actual dependencies as possible.  With your change
all of the other source files will load in and parse if_vlan.h
even though they have no need for it.
