From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ibmveth: Return correct error codes
Date: Sat, 13 Feb 2016 05:58:44 -0500 (EST)
Message-ID: <20160213.055844.351786875045113025.davem@davemloft.net>
References: <20160204135519.GA8362@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160204135519.GA8362@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Thu, 4 Feb 2016 19:25:19 +0530

> The return value of kmalloc and kcalloc on failure of allocation of
> memory should be -ENOMEM and not -1.
> 
> Found using Coccinelle. A simplified version of the semantic patch
> used is:
 ...
> The two call sites only check that the return value is not 0,
> hence no change is required at the call sites.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

This does not apply cleanly and gives rejects.
