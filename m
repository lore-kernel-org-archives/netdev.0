From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: Bad checksum on bridge with IP options
Date: Sun, 11 May 2014 21:42:40 +0200
Message-ID: <DUB123-W15AFD3F815E035C19E3BF9ED4A0@phx.gbl>
References: <536F8C0F.4090206@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: David Newall <davidn@davidnewall.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s34.dub0.hotmail.com ([157.55.2.109]:25873 "EHLO
	dub0-omc4-s34.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932919AbaEKTmm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 May 2014 15:42:42 -0400
In-Reply-To: <536F8C0F.4090206@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


> I've been chasing a ping problem with record-route set, and it looks
> like a bug. The problem also occurs with timestamp option set.
> Everything works find when using just the nic, or bonded nics, but
> breaks when I use a bridge. This is 100% repeatable.
>
> This fault has been observed on amd64 architecture running Ubuntu 13.10
> with various Canonical supplied kernels, and running Ubuntu 14.04 with
> Canonical supplied kernel 3.13.0-24-generic.

I think you will have to reproduce this on a vanilla kernel.org kernel
like 3.14.3 and 3.15-rc5 [1] ...


Lukas


[1] http://kernel.ubuntu.com/~kernel-ppa/mainline/

 		 	   		  