From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing tcp
 socket be atomic
Date: Wed, 03 Feb 2010 18:19:31 -0800 (PST)
Message-ID: <20100203.181931.39810642.davem@davemloft.net>
References: <474C17045AA24E3F8519EE76BAB47439@JOHNYE1>
	<20100203.085249.98326242.davem@davemloft.net>
	<DB4F116661E3B0428456BB7E379EF4BB3C5F57@MX.asimcotech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, jmorris@namei.org,
	kaber@coreworks.de, linux-kernel@vger.kernel.org
To: johny@asimco.com.cn
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DB4F116661E3B0428456BB7E379EF4BB3C5F57@MX.asimcotech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John Ye" <johny@asimco.com.cn>
Date: Thu, 4 Feb 2010 10:03:44 +0800

> The option TCP_ATOMIC is not a must.  We can make atomic be default
> if the data size is less than a fixed size, just the same as pipe.
> For example, if the data size is less than 512, we don't split the
> data so it goes atomically.

This completely ignores the core issue.

And that is, for the second time, that the application is where such
atomicity guarentees should be implemented.

And because of that any implementation of your kernel changes are
inappropriate, TCP_ATOMIC socket option or not.
