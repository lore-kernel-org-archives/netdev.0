From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Tue, 15 Feb 2005 15:42:48 -0800
Message-ID: <421288F8.7090501@hp.com>
References: <0525M9211@server5.heliogroup.fr>	<20050211150420.74737b2e@dxpl.pdx.osdl.net>	<20050211170740.2608419b.davem@davemloft.net>	<20050212141641.GA27456@yakov.inr.ac.ru>	<20050212114132.5f7b7ffe.davem@davemloft.net>	<20050212200318.GB28895@yakov.inr.ac.ru> <20050215152651.58f5ccc0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <20050215152651.58f5ccc0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> In short, for properly working TCP stream with no drops and no
> reordering, Darwin delays ACKs until delack timer fires or PSH
> is seen :-)

As a supporter of ACK avoidance heuristics in general, I will come-out and say 
that the heuristic above does indeed sound quite broken.  It is not the 
heuristic with which I am familiar, which has a configurable maximum number of 
segments for which to delay the ACK.

rick jones
