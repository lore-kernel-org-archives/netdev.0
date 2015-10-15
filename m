From: Nick Alcock <nix@esperi.org.uk>
Subject: Re: [PATCH net 1/1] via-rhine: fix VLAN receive handling regression.
Date: Thu, 15 Oct 2015 08:24:51 +0100
Message-ID: <8737xck30c.fsf@esperi.org.uk>
References: <20151014221437.GA8065@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrej Ota <andrej@ota.si>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:41927 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbJOIZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 04:25:05 -0400
In-Reply-To: <20151014221437.GA8065@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Thu, 15 Oct 2015 00:14:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 Oct 2015, Francois Romieu told this:

> From: Andrej Ota <andrej@ota.si>
>
> Because eth_type_trans() consumes ethernet header worth of bytes, a call
> to read TCI from end of packet using rhine_rx_vlan_tag() no longer works
> as it's reading from an invalid offset.
>
> Tested to be working on PCEngines Alix board.

LGTM, though not tested because I don't have any vlans set up on my VIA
Rhine box and I can't reboot it at the moment. :)
