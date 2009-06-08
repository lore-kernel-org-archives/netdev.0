From: David Miller <davem@davemloft.net>
Subject: Re: SMC91x: forcing speed
Date: Mon, 08 Jun 2009 14:44:45 -0700 (PDT)
Message-ID: <20090608.144445.72867560.davem@davemloft.net>
References: <ba4215e10906080502u3966a301vb2d7162f48694a4b@mail.gmail.com>
	<20090608.142257.141336772.davem@davemloft.net>
	<4A2D85D7.6050509@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.rojfors@endian.se, nico@cam.org, netdev@vger.kernel.org
To: mfuzzey@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57767
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbZFHVoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:44:44 -0400
In-Reply-To: <4A2D85D7.6050509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Fuzzey <mfuzzey@gmail.com>
Date: Mon, 08 Jun 2009 23:42:47 +0200

> IMHO the place for board specific hacks is in the board specifc startup
> code - am I wrong?

We never add bootup time hacks for things that already have
a suitable generic and clean configuration interface.

People ask for module options and all kinds of crap like that
to set link parameters, and we always say no.
