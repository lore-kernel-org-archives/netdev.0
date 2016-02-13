From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: mvpp2: Return correct error codes
Date: Sat, 13 Feb 2016 05:58:59 -0500 (EST)
Message-ID: <20160213.055859.1000054958176745984.davem@davemloft.net>
References: <20160204135526.GA8400@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160204135526.GA8400@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Thu, 4 Feb 2016 19:25:26 +0530

> The return value of kzalloc on failure of allocation of memory should
> be -ENOMEM and not -1.
> 
> Found using Coccinelle. A simplified version of the semantic patch
> used is:
 ...
> This function may also return -1 after calling mpp2_prs_tcam_port_map_get.
> So that the function consistently returns meaningful error values on 
> failure, the -1 is changed to -EINVAL.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
