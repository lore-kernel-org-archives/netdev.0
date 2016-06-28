From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: Remove unneeded header file
Date: Tue, 28 Jun 2016 05:26:28 -0400 (EDT)
Message-ID: <20160628.052628.752695490149507663.davem@davemloft.net>
References: <20160624062354.GA23515@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624062354.GA23515@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Fri, 24 Jun 2016 11:53:54 +0530

> Drop redundant include of moduleparam.h
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @ includesmodule @
> @@
> 
> #include <linux/module.h>
> 
> @ depends on includesmodule @
> @@
> 
> - #include <linux/moduleparam.h>
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied, thanks.
