From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 11:55:25 -0500
Message-ID: <1451494525.8255.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5681AF69.4040204@redhat.com> <5681B594.70304@iogearbox.net>
	 <5681E154.7040101@redhat.com>
	 <20151230034300.GA8670@ast-mbp.thefacebook.com>
	 <5683531F.9000704@redhat.com>
	 <20151230041611.GA9209@ast-mbp.thefacebook.com>
	 <5683A630.2070401@iogearbox.net> <20151230151123.GB4874@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Doug Ledford <dledford@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35170 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbbL3Qz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 11:55:28 -0500
Received: by mail-pf0-f173.google.com with SMTP id 78so144184321pfw.2
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 08:55:28 -0800 (PST)
In-Reply-To: <20151230151123.GB4874@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 10:11 -0500, Dave Jones wrote:
> On Wed, Dec 30, 2015 at 10:38:56AM +0100, Daniel Borkmann wrote:
> 
>  > Given that this drop doesn't strictly need to be caused by filter code,
>  > it would be nice if you could pin the location down where the packet gets
>  > dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb -a -g
>  > dhclient <iface>', etc could help to get a first overview to dig into
>  > details then.
> 
> Wild stab in the dark, but..
> Could this bug be another symptom fixed by http://article.gmane.org/gmane.linux.network/392885 ?

dhclient does not use async io
