From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 20:57:58 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802052056120.16441@fbirervta.pbzchgretzou.qr>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
 <20080205155558.GA23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33675 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbYBET57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 14:57:59 -0500
In-Reply-To: <20080205155558.GA23145@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 5 2008 16:55, Andi Kleen wrote:
>On Mon, Feb 04, 2008 at 03:01:01PM -0800, Glenn Griffin wrote:
>> Add IPv6 support to TCP SYN cookies.  This is written and tested against
>> 2.6.24, and applies cleanly to linus' current HEAD (d2fc0b).  Unfortunately
>> linus' HEAD breaks my sky2 card at the moment, so I'm unable to test against
>> that.  I see no reason why it would be affected though.  Comments/suggestions
>> are welcome.
>
>Syncookies are discouraged these days. They disable too many 
>valuable TCP features (window scaling, SACK) and even without them 
>the kernel is usually strong enough to defend against syn floods
>and systems have much more memory than they used to be.
>
>So I don't think it makes much sense to add more code to it, sorry.

Distributions should then probably deactivate it by default.
SUSE 10.3 for example still has it enabled on default installs.
