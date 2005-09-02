From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Fri, 2 Sep 2005 17:48:07 +0400
Message-ID: <20050902134807.GB12617@yakov.inr.ac.ru>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <2d02c76a84655d212634a91002b3eccd@psc.edu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> If you overflow the socket's memory bound, it ends up calling 
> tcp_clamp_window().  (I'm not sure this is really the right thing to do 
> here before trying to collapse the queue.)

Collapsing is too expensive procedure, it is rather an emergency measure.
So, tcp collapses queue, when it is necessary, but it must reduce window
as well.

Alexey
