From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 10:30:54 -0400
Message-ID: <1175697054.4063.13.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
	 <4613A9F6.8000307@trash.net> <1175695102.4063.4.camel@localhost>
	 <4613B13C.3010603@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:43304 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbXDDOa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:30:59 -0400
Received: by an-out-0708.google.com with SMTP id b33so251279ana
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 07:30:58 -0700 (PDT)
In-Reply-To: <4613B13C.3010603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 16:07 +0200, Patrick McHardy wrote:

> He only used a single redirect to eth0.5, but its probably due to the
> fact that the VLAN hard_start_xmit function transmits on eth0 again.

Ok, that validates what i was saying earlier then - so i dont need to
run the test.

> How about adding something like ifb's ri_tasklet to act_mirred?

You mean having a tasklet or the constraint checks?

cheers,
jamal

