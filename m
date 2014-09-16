From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Tue, 16 Sep 2014 10:37:41 +0200
Message-ID: <1410856661.1539893.168008809.76DF2C8C@webmail.messagingengine.com>
References: <54170FC0.6020907@oktetlabs.ru> <1410822949.5018.4.camel@localhost>
 <1410832228.7106.170.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36531 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314AbaIPIhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 04:37:42 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 86ACA207A6
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 04:37:41 -0400 (EDT)
In-Reply-To: <1410832228.7106.170.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Sep 16, 2014, at 03:50, Eric Dumazet wrote:
> 
> Why ? If a TARPIT module always answer to zero window probes, these
> sessions would last forever.

The first paragraph from the original mail didn't read like it would
constantly answer to the zero win probes, but after looking at the
attack.lua source I come to the same conclusion.

Bye,
Hannes
