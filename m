From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] net: mv643xx_eth: use kzalloc
Date: Wed, 09 Sep 2015 11:45:56 -0700
Message-ID: <1441824356.17219.69.camel@perches.com>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1441814431.17219.46.camel@perches.com> <87r3m74f2k.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0002.hostedemail.com ([216.40.44.2]:45744 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750819AbbIISp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 14:45:59 -0400
In-Reply-To: <87r3m74f2k.fsf@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-09 at 20:34 +0200, Rasmus Villemoes wrote:
> mc_spec and mc_other are u32*, we allocate 0x200 = 512 bytes = 128
> u32s, and pointer arithmetic makes mc_other point to the latter 64. Then
> the memory is cleared 256 bytes at a time.
> 
> It's unusual and slightly obfuscated code, but I don't think it's
> wrong. 

Right, misread.
