From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:06:40 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0505171501510.3184@linux.site>
References: <m1k6lx7gkf.fsf@muc.de> <20050517.132202.59028935.davem@davemloft.net>
 <20050517202730.GA79960@muc.de> <20050517.140245.71090021.davem@davemloft.net>
 <428A613F.1020303@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <428A613F.1020303@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Tue, 17 May 2005, Rick Jones wrote:

> ....
> or an added heuristic of "if have reassembled N datagrams for the same
> source/dest/protocol tuple with ID's "larger" than 'this one' since it has
> arrived, we are probably going to wrap so might as well drop 'this one'"  for
> some judicious and magical selection of N that may be a decent predictor of
> wrap on top of some existing reassembly timout.
> ....

How do you define "larger" in this case? A sender is free to choose 
any ID - they can't be assumed to be montonic, for sure. 

--
Arthur
