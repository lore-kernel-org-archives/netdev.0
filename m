From: CaT <cat@zip.com.au>
Subject: Re: strange network slowness in 2.6 unless pingflooding
Date: Wed, 29 Sep 2004 15:50:37 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040929055036.GA25016@zip.com.au>
References: <20040927090342.GA1794@zip.com.au> <41587A26.6020606@conectiva.com.br> <20040927224957.GA1043@zip.com.au> <20040927161845.1442bb4a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927161845.1442bb4a.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 04:18:45PM -0700, David S. Miller wrote:
> In particular, if there are hubs or switches involved on
> your local network that might be getting the duplex wrong,
> or some NAT or firewall machines in the path in question,
> please specify their setup precisely.
> 
> Otherwise there is zero chance of this problem ever being
> fixes.

Well I was going to do a few more tests and send a nice email doing just
that but in going through my package list with dpkg I spotted cpudyn and
cpufreqd installed. I've uninstalled them and now I cannot reproduce
the problem.

As such, and I hope I'm not speaking to you, it appears 'solved'. They
must've been interfering with the network layer somehow (or something)
and now that they are gone all's well.

My apologies if anyones time was wasted.

-- 
    Red herrings strewn hither and yon.
