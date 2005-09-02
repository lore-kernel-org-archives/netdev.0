From: John Heffner <jheffner@psc.edu>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x kernels
Date: Fri, 2 Sep 2005 10:11:12 -0400
Message-ID: <c3182a5b461b404e1672c45c3a91897d@psc.edu>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu> <43184D79.6040009@mrv.com> <20050902135256.GC12617@yakov.inr.ac.ru>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ion Badulescu <lists@limebrokerage.com>,
	Guillaume Autran <gautran@mrv.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20050902135256.GC12617@yakov.inr.ac.ru>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 2, 2005, at 9:52 AM, Alexey Kuznetsov wrote:

> Hello!
>
>> I experienced the very same problem but with window size going all the
>> way down to just a few bytes (14 bytes). dump files available upon
>> requests :)
>
> I do request.
>
> TCP is not allowed to reduce window to a value less than 2*MSS no 
> matter
> how hard network device or peer try to confuse it. :-)

You're right, that doesn't make sense...

