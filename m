From: Andi Kleen <andi@firstfloor.org>
Subject: Re: What were the reasons of having mandatory IP address at AX.25 interfaces ?
Date: Mon, 04 Feb 2008 15:38:35 +0100
Message-ID: <p731w7s4wic.fsf@bingen.suse.de>
References: <S3540591AbYBCSQN/20080203181613Z+1592@mail.zmailer.org>
	<47A60A57.5080402@digitalrealm.net>
	<20080203202819.GX2537@mea-ext.zmailer.org>
	<20080204130252.GA2537@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Matti Aarnio <matti.aarnio@zmailer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49839 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472AbYBDOih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 09:38:37 -0500
In-Reply-To: <20080204130252.GA2537@mea-ext.zmailer.org> (Matti Aarnio's message of "Mon\, 4 Feb 2008 15\:02\:52 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Aarnio <matti.aarnio@zmailer.org> writes:

> .. the original reason was apparently that _ifconfig_ blew up
> when it saw protocols that it didn't understand on network
> interfaces.  Possibly when there was no IP protocol on an
> interface.

It's not only ifconfig, a lot of programs use SIOCGIFCONF
to query ip addresses.

-Andi
