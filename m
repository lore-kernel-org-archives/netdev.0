From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Mon, 29 Sep 2003 09:29:19 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309290927460.15163-100000@netcore.fi>
References: <20030928225941.GW15338@fs.tum.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <davem@redhat.com>,
        <lksctp-developers@lists.sourceforge.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20030928225941.GW15338@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003, Adrian Bunk wrote:
> It seems modular IPv6 doesn't work 100% reliable, e.g. after looking at 
> the code it doesn't seem to be a good idea to compile a kernel without 
> IPv6 support and later build and install IPv6 modules. Is there a great 
> need for modular IPv6 or is the patch below to disallow modular IPv6 OK?

IPv6 modularity is critical for all the Linux distributions who wish to
give the users the possibility to turn on IPv6 if they wish, but turning
it on by default for everybody is not realistic.

IMHO, making it non-modular is *NOT* an option.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
