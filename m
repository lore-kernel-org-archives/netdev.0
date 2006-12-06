From: Stefan Rompf <stefan@loplof.de>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 20:32:40 +0100 (MET)
Message-ID: <200612062033.34754.stefan@loplof.de>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
 <1165148731.12649.51.camel@pmac.infradead.org>
 <20061204091341.GM8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:13714 "EHLO
	mo-p07-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937451AbWLFTeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 14:34:31 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061204091341.GM8693@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 4. Dezember 2006 10:13 schrieb Thomas Graf:

> I do not agree with the change to include if_addr.h in rtnetlink.h.
> The point is to move bits apart and have multiple small pieces
> of header files defining a specific rtnetlink family which are a
> lot easier to maintain for both kernel and userspace than one giant
> rtnetlink.h for everything.

According to a user's report, your change also broke compilation of my 
dhcpclient because it neeeds if_addr.h since 2.6.19. Any suggestion how to 
make one source code build on 2.6.19 and older headers? I hope you don't want 
me to check on UTS_RELEASE in a userspace program?

Stefan
