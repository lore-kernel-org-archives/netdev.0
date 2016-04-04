From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Mon, 04 Apr 2016 09:37:47 +0200
Message-ID: <1459755467.18188.16.camel@sipsolutions.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	 <1459622491.18188.6.camel@sipsolutions.net>
	 <CALx6S35kK9eNk8r-fZmP-mOSB=Tb8udbaQeSUjmHWJagh+=i=A@mail.gmail.com>
	 <CAKD1Yr351bEXwBOj8e8Hq=_u7J4Zi2-r=w3k9Z3XFe0AP4m5aw@mail.gmail.com>
	 (sfid-20160403_042824_139777_98CD13EB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Lorenzo Colitti <lorenzo@google.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44808 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386AbcDDHhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 03:37:52 -0400
In-Reply-To: <CAKD1Yr351bEXwBOj8e8Hq=_u7J4Zi2-r=w3k9Z3XFe0AP4m5aw@mail.gmail.com> (sfid-20160403_042824_139777_98CD13EB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-04-03 at 11:28 +0900, Lorenzo Colitti wrote:

> That said, getting BPF to the driver is part of the picture. On the
> chipsets we're targeting for APF, we're only seeing 2k-4k of memory
> (that's 256-512 BPF instructions) available for filtering code, which
> means that BPF might be too large.

That's true, but I think that as far as the userspace API is concerned
that shouldn't really be an issue. I think we can compile the BPF into
APF, similar to how BPF can be compiled into machine code today.
Additionally, I'm not sure we can realistically expect all devices to
really implement APF "natively", I think there's a good chance but
there's also a possibility of compiling to the native firmware
environment, for example.

johannes
