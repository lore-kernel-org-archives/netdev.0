From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Fri, 2 Sep 2005 17:52:56 +0400
Message-ID: <20050902135256.GC12617@yakov.inr.ac.ru>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>,
	Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751319AbVIBNxT@vger.kernel.org>
To: Guillaume Autran <gautran@mrv.com>
Content-Disposition: inline
In-Reply-To: <43184D79.6040009@mrv.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I experienced the very same problem but with window size going all the 
> way down to just a few bytes (14 bytes). dump files available upon 
> requests :)

I do request.

TCP is not allowed to reduce window to a value less than 2*MSS no matter
how hard network device or peer try to confuse it. :-)

Alexey
