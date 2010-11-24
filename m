From: David Miller <davem@davemloft.net>
Subject: Re: Unplug ethernet cable, the route persists. Why?
Date: Wed, 24 Nov 2010 12:44:52 -0800 (PST)
Message-ID: <20101124.124452.212692883.davem@davemloft.net>
References: <20101124121826.39dd6ed1@nehalam>
	<144174.46619.qm@web63401.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: caoco2002@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40738
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172Ab0KXUo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 15:44:27 -0500
In-Reply-To: <144174.46619.qm@web63401.mail.re1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Caoco <caoco2002@yahoo.com>
Date: Wed, 24 Nov 2010 12:29:43 -0800 (PST)

> Even when no NetworkManager/Quagga is present, I think it is a
> legitimate reason to recompute the route when a cable is unplugged,
> which should not be a frequent event unless when under error
> conditions.

Cards periodically reset themselves, faulty switchs flap occaisionally,
this is life and it shouldn't cause route table recomputations across
your entire region.

Also Stephen listed places where such policy should be employed in
userspace, he absolutely did not say they should act that way by
default.
