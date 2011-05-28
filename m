From: Bernd Zeimetz <bzed@debian.org>
Subject: Re: [Bugme-new] [Bug 35992] New: Regression: oops when using a bridge
 interface with tg3
Date: Sat, 28 May 2011 10:58:06 +0200
Message-ID: <4DE0B91E.1080407@debian.org>
References: <bug-35992-10286@https.bugzilla.kernel.org/> <20110527152158.0453899d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.recluse.de ([217.196.146.213]:57999 "EHLO mail.recluse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916Ab1E1JFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2011 05:05:21 -0400
In-Reply-To: <20110527152158.0453899d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2011 12:21 AM, Andrew Morton wrote:
> 2.6.38->2.6.39 regression, appears to be bridge-related.  There's a
> partial screencap of the oops linked below.

The oops happens as soon as I add the lxc veth interface to the bridge, before
everything works as expected.


A new, full screenshot is attached
https://bugzilla.kernel.org/attachment.cgi?id=59732


(For yet unknows reasons I can't access the serial port redirection via ssh and
I won't be able to attach a real serial port cable before Monday, so I'm afraid
you have to work with the screenshot for now.)


> Bernd, it would be helpful if you could set the screen to more rows
> (50?) and then retake that photo.  Documentation/svga.txt might help
> out.  Thanks.

(the kernel says that vga=... is deprecated, guess that documentation is outdated?)

Thanks and cheers,

Bernd

-- 
 Bernd Zeimetz                            Debian GNU/Linux Developer
 http://bzed.de                                http://www.debian.org
 GPG Fingerprint: ECA1 E3F2 8E11 2432 D485  DD95 EB36 171A 6FF9 435F
