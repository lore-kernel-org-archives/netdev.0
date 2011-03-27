From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: bridge: mcast snooping, fixes for IPv6 MLDv1/2 parsing
Date: Sun, 27 Mar 2011 08:27:22 +0200
Message-ID: <1301207244-10428-1-git-send-email-linus.luessing@web.de>
References: <20110327034404.GC31916@Sellars>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:52337 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587Ab1C0G1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 02:27:36 -0400
In-Reply-To: <20110327034404.GC31916@Sellars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

The following two patches are fixing two issues, related to the parsing of
IPv6 MLD messages.

The first one fixes an observed issue which lead to ignored MLD messages.
In the tests this patch fixes the issue in my scenario. However I'm not
so familiar with the checksumming functions in the kernel, so would be
great if someone could double-check whether the new checksum calculations
make sense like this.

The second patch fixes a potential issue. Bogus values of the 'len' variable
had been observed during tests and this patch successfully fixed this
here. However this patch is untested for the potential issues named
in the patch's description that could have occured without it.

Both patches together have been applied and tested and no more
issues with the parsing and adding of new IPv6 multicast listeners to
the bridge snooping database could be observed (for now ;) ).

Cheers, Linus
