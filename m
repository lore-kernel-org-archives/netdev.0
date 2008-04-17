From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Wake on LAN doesn't work with r8169
Date: Thu, 17 Apr 2008 23:02:09 +0200
Message-ID: <20080417210209.GA22452@electric-eye.fr.zoreil.com>
References: <20080417163721.GA2442@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46069 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbYDQVVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:21:16 -0400
Content-Disposition: inline
In-Reply-To: <20080417163721.GA2442@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucas Nussbaum <lucas.nussbaum@imag.fr> :
[...]
> If I modify my shutdown script to leave the interface up, WOL works.
> This is inconvenient, because most cards have the opposite behaviour
> (WOL usually works when the interface is put down).

You have a point (assuming ethtool is used to enable WOL).

> Since the driver explicitely mentions WOL in the suspend/resume code, I
> tried that too, but couldn't get the system to wake up using WOL. (has
> this been confirmed to work?)
> 
> The r8168 driver from Realtek has the same behaviour.
> 
> Any clues?

It has been confirmed to work, see:

http://bugzilla.kernel.org/show_bug.cgi?id=9512

-- 
Ueimor
