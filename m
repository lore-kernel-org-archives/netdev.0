From: Reinhard Karcher <reinhard.karcher@gmx.net>
Subject: Re: Bug#664064: linux-image-3.3.0-rc6-amd64: 4 messages every minute
 in syslog from netlink
Date: Fri, 16 Mar 2012 09:53:43 +0100
Message-ID: <4F62FF97.9080105@gmx.net>
References: <20120315120008.14655.64028.reportbug@apollon> <1331831653.3022.228.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: 664064@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:32774 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1422635Ab2CPIxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:53:47 -0400
In-Reply-To: <1331831653.3022.228.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 15.03.2012 18:14, schrieb Ben Hutchings:
> It would be useful if we could tell which program is sending the
> message, but I think that may be difficult to do.
>

Some further investigation showed that the 1st occurrence of the message 
is related to the start of KDE. After stopping X (and KDE) there are no 
new messages logged.

Reinhard
