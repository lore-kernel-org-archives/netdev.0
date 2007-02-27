From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [BUG][2.6.21] af_key: kernel BUG at net/core/skbuff.c:93
Date: Tue, 27 Feb 2007 10:01:27 +0100
Message-ID: <20070227090127.GA1625@ff.dom.local>
References: <20070226220841.GA7727@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:43902 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751467AbXB0I5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 03:57:48 -0500
Content-Disposition: inline
In-Reply-To: <20070226220841.GA7727@dreamland.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26-02-2007 23:08, Luca Tettamanti wrote:
> Hello,
> I'm running 2.6.21 (current git, at 9654640d0af). kernel blows up at
> startup, when running setkey. Kernel 2.6.20 runs fine. A couple of words
...
> ------------[ cut here ]------------
> kernel BUG at /home/kronos/src/linux-2.6.git/net/core/skbuff.c:93!
> invalid opcode: 0000 [#1]

Hi!

Could you repeat this with: CONFIG_4KSTACKS=n ?

Regards,
Jarek P.
