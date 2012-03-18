From: Reinhard Karcher <reinhard.karcher@gmx.net>
Subject: Re: Bug#664064: linux-image-3.3.0-rc6-amd64: 4 messages every minute
 in syslog from netlink
Date: Sun, 18 Mar 2012 11:59:05 +0100
Message-ID: <4F65BFF9.2050002@gmx.net>
References: <20120315120008.14655.64028.reportbug@apollon>  <1331831653.3022.228.camel@deadeye> <4F622E92.9010007@gmx.net> <1332040554.31699.22.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 664064@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:57758 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753397Ab2CRK7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 06:59:08 -0400
In-Reply-To: <1332040554.31699.22.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.03.2012 04:15, schrieb Ben Hutchings:
> OK, so it's something running in your KDE session.  And the results
> you got from lsof suggest that it's some kind of network monitor
> that's hosted by kded4, using the ntrack library
> <https://launchpad.net/ntrack>.  I've never heard of this before.
>
> ntrack appearently has the option to use either libnl or its own
> built-in netlink protocol code, and is using the latter on your
> system. If you install ntrack-module-libnl-0 and remove
> ntrack-module-rtnetlink-0, does this fix the problem?
>

Yes, that fixes the problem. Thanks for your help.
Should the bug be filed against an other package?
kde-runtime -> libntrack-qt4-1 -> libntrack0 -> ntrack-module-rtnetlink-0
Which one from the packages above?

Reinhard
