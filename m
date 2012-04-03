From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 08:36:20 +0200
Message-ID: <dc6e3bc8b96d91bd7ce44639b60cfec2@chewa.net>
References: <1333398660-11552-1-git-send-email-levinsasha928@gmail.com> <201204022201.41808.remi@remlab.net> <20120402.174006.70116829696492189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <levinsasha928@gmail.com>, <davej@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120402.174006.70116829696492189.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 02 Apr 2012 17:40:06 -0400 (EDT), David Miller=0D
<davem@davemloft.net> wrote:=0D
> UDP generates a fragment list of MTU sized SKBs.=0D
> =0D
> Phonet could avoid the large allocations by building page based=0D
> SKBs.=0D
=0D
Oh right. And Phonet devices don't support scatter/gather, so that I gu=
ess=0D
that would merely delay the problem.=0D
=0D
Also sendmsg() code would need to be reectored to look up the output=0D
device and then the MTU before allocating the socket buffer. This will =
only=0D
work if the default MTU is reduced first :/=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
Sent from my collocated server
