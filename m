From: Arun Sharma <asharma@fb.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Mon, 30 Jan 2012 14:13:10 -0800
Message-ID: <20120130221310.GA10481@dev3310.snc6.facebook.com>
References: <inTpE-FS-29@gated-at.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, mohan@fb.com,
	Glauber Costa <glommer@parallels.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <inTpE-FS-29@gated-at.bofh.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Note#2, the message should probably be fixed as well:
> 
>  -   TCP: too many of orphaned sockets                     
>  +   TCP: too many orphaned sockets                     
> 

There is a third problem: we see this message even when the number of
orphaned sockets is below the limit.

I'll send out a patch to disambiguate the message.

 -Arun
