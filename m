From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] proc_fs.h redux
Date: Sun, 28 Oct 2007 11:43:50 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0710281143250.30465@fbirervta.pbzchgretzou.qr>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru>
 <1193524804.26695.103.camel@localhost> <20071028103415.GA12554@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, akpm@osdl.org,
	torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Russell King <rmk+lkml@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:45948 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbXJ1Knv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 06:43:51 -0400
In-Reply-To: <20071028103415.GA12554@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 28 2007 10:34, Russell King wrote:
>On Sat, Oct 27, 2007 at 03:40:04PM -0700, Joe Perches wrote:
>> and forward declarations of
>> 
>> struct proc_dir_entry;
>> struct file_operations;
>> 
>> As a general rule, I think it better to use includes
>> than use naked forward declarations.
>
>If you go down that route, you end up with _lots_ of circular
>dependencies - header file X needs Y needs Z which needs X.  We've
>been there, several times.  It very quickly becomes quite
>unmaintainable - you end up with hard to predict behaviour from
>include files.
>
>The only realistic solution is to use forward declarations.

Especially because it reduces the amount of I/O that needs to be done.

