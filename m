From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Return correct error code
Date: Thu, 11 Feb 2016 09:44:09 -0500 (EST)
Message-ID: <20160211.094409.391383365173722850.davem@davemloft.net>
References: <20160207052624.GA9263@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160207052624.GA9263@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Sun, 7 Feb 2016 10:56:25 +0530

> The return value of kzalloc on failure of allocation of memory should
> be -ENOMEM and not -1.
> 
> Found using Coccinelle. A simplified version of the semantic patch
> used is:
 ...
> The single call site only checks that the return value is not 0,
> hence no change is required at the call site.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied, thanks.
