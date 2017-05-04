From: Joe Perches <joe@perches.com>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 10:47:51 -0700
Message-ID: <1493920071.22125.37.camel@perches.com>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
         <20170504.124600.627647229351638856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170504.124600.627647229351638856.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-05-04 at 12:46 -0400, David Miller wrote:
> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Thu, 04 May 2017 11:07:54 -0500
> 
> > While looking into Coverity ID 1357474 I ran into the following piece
> > of code at net/ipv4/inet_diag.c:392:
> 
> Because it's been this way since at least 2005, it doesn't matter if
> the order is correct or not.  What's there is the locked in behavior
> exposed to userspace and changing it will break things for people.

Adding a few comments around the code about why
it is this way will help avoid future questions.
