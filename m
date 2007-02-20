From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking
	UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 23:22:27 +0100
Message-ID: <1172010148.3531.158.camel@laptopd505.fenrus.org>
References: <20070219231447.GA4400@outpost.ds9a.nl>
	 <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl>
	 <20070220164124.GA24930@2ka.mipt.ru>
	 <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
	 <20070220184859.GA1949@2ka.mipt.ru> <20070220193319.GA8800@outpost.ds9a.nl>
	 <45DB6FD8.4050106@hp.com>  <20070220221719.GA16263@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34660 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030491AbXBTWWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 17:22:50 -0500
In-Reply-To: <20070220221719.GA16263@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm trying to figure out which processes have the most impact, I had already
> killed anything non-essential. But that still leaves 140 pids.

btw if you have systemtap on your system you can see who is doing evil
with

http://www.fenrus.org/cstop.stp

also.. running "vmstat 3" and looking at the "cs" column is interesting;
it shouldn't be above 50 or so in idle (well not above 10 but our
userland stinks too much for that)


