From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Sat, 7 Jul 2007 23:10:27 +0200
Message-ID: <200707072310.28160.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <20070702215621.GA18766@electric-eye.fr.zoreil.com> <200707032000.52243.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jens Stroebel <drifter@bcsoft.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:51904 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbXGGVKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 17:10:31 -0400
In-Reply-To: <200707032000.52243.peter.missel@onlinehome.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi again Francois!

> > No NFS but networking or no networking at all ?
>
> Networking in itself was fine and stable, and with seemingly much better
> performance in large file transfers as well.
>
> NFS appeared to be working too, problem was just that workstation and
> server couldn't agree on file locking procedures anymore, and all existing
> files could only be read but not written to. This proved quite
> unproductive, so I had to revert.

I've been browsing bug lists a bit, and seem to suffer exactly from this one:

https://bugzilla.novell.com/show_bug.cgi?id=272268

... whenever I use an updated kernel (2.6.21.5 or 2.6.22-rc7) on the client 
end. The original 2.6.18.8.0-3 SuSE kernel works fine, and updating the 
server as well doesn't help.

Ideas welcome.

g'night.
Peter
