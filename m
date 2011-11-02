From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix WOL in power down case
Date: Thu, 3 Nov 2011 00:08:27 +0100
Message-ID: <20111102230827.GA8974@electric-eye.fr.zoreil.com>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de> <20111007210017.GA27820@electric-eye.fr.zoreil.com> <20111007214200.GA28365@electric-eye.fr.zoreil.com> <20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de> <20111007232834.GA29770@electric-eye.fr.zoreil.com> <20111009104907.0c6cd439900ca5eb7789295f@gmx.de> <20111009115438.GA12343@electric-eye.fr.zoreil.com> <20111009191331.cbfca0b6b724921f35fd8c41@gmx.de> <loom.20111101T174532-579@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stefan Becker <chemobejk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43552 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452Ab1KBXMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 19:12:37 -0400
Content-Disposition: inline
In-Reply-To: <loom.20111101T174532-579@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Becker <chemobejk@gmail.com> :
[...]
> I just upgraded to Fedora 16 with Kernel 3.1.0 and WoL stopped working in the
> power down case on my R8168 :-(

Plain power down, not suspend/resume ?

[...]
> According to the code the combination "RTL8168c/8111c" means RTL_GIGA_MAC_VER_19
> to _22, so the code changes in the fix commit don't apply to them. Could it be
> that the fix doesn't cover all the necessary HW?

Yes.

However I am almost sure the regression would come from a different commit
and I'd rather identify it. Can you narrow the kernel version a bit ?
Your vendor's kernel identifier before regression would be a good start.

-- 
Ueimor
