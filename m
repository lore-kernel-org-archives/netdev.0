From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Mon, 11 Jan 2016 13:47:50 -0800
Message-ID: <1452548870.1223.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5726932.6r4XOZ2Km2@rofl>
	 <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56492A39.2060307@fastly.com>
	 <1447686469.22599.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <564A129F.5060705@fastly.com> <56941035.9040000@fastly.com>
	 <1452546688.1223.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick Schaaf <kernelorg@bof.de>,
	NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452546688.1223.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-01-11 at 13:11 -0800, Eric Dumazet wrote:

> 
> Hi Grant
> 
> Most probably the commit would help ;)
> 
> David, can you make sure ed2e923945892a8372ab70d2f61d364b0b6d9054 is
> pushed to stable trees (4.1 & 4.2)

We also want this fix:

commit 8695a144da9e500a5a60fa34c06694346ec1048f
    tcp/dccp: fix old style declarations
    
