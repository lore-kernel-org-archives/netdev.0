From: "David Schwartz" <davids@webmaster.com>
Subject: RE: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Sun, 25 Nov 2007 07:41:52 -0800
Message-ID: <MDEHLPKNGKAHNMBLJOLKCENAIGAC.davids@webmaster.com>
References: <E1Ivo4H-0006Z2-00@gondolin.me.apana.org.au>
Reply-To: davids@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:1145 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbXKYPlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 10:41:40 -0500
In-Reply-To: <E1Ivo4H-0006Z2-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> David Schwartz <davids@webmaster.com> wrote:

> >> Regardless of whatever verifications your application is doing
> >> on the data, it is not checksumming the ports and that's what
> >> the pseudo-header is helping with.

> > So what? We are in the case where the data has already gotten
> > to him. If it
> > got to him in error, he'll reject it anyway. The receive
> > checksum check will
> > only reject packets that he would reject anyway. That makes it needless.

> What if it goes to the wrong recipient who doesn't have the upper-
> level checksums?

Since that's not him, he has no control over its policy and thus no ability
to harm it or help it.

> This is the whole point, IPv6 unlike IPv4 does not have IP header
> checksums so the high-level needs to protect it by checksumming
> the pseudo-header.

Exactly. But *he* doesn't need to check that checksum, given that he already
got the packet, since he has an upper-level checksum. He is not saying that
his reasoning applies to everyone, just that it applies to him. He is not
talking about disabling the send checksum, but the receive checksum. He
knows that he does not need it.

DS


