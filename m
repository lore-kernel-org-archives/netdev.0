From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 10:11:23 -0500
Message-ID: <20151230151123.GB4874@codemonkey.org.uk>
References: <5681AF69.4040204@redhat.com>
 <5681B594.70304@iogearbox.net>
 <5681E154.7040101@redhat.com>
 <20151230034300.GA8670@ast-mbp.thefacebook.com>
 <5683531F.9000704@redhat.com>
 <20151230041611.GA9209@ast-mbp.thefacebook.com>
 <5683A630.2070401@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:51322 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbL3PLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 10:11:35 -0500
Content-Disposition: inline
In-Reply-To: <5683A630.2070401@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 10:38:56AM +0100, Daniel Borkmann wrote:

 > Given that this drop doesn't strictly need to be caused by filter code,
 > it would be nice if you could pin the location down where the packet gets
 > dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb -a -g
 > dhclient <iface>', etc could help to get a first overview to dig into
 > details then.

Wild stab in the dark, but..
Could this bug be another symptom fixed by http://article.gmane.org/gmane.linux.network/392885 ?

	Dave
