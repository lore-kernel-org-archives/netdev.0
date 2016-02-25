From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: Use kobj_to_dev()
Date: Thu, 25 Feb 2016 16:52:23 -0500 (EST)
Message-ID: <20160225.165223.1699552403031314424.davem@davemloft.net>
References: <20160224143938.GA17198@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160224143938.GA17198@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 24 Feb 2016 20:09:38 +0530

> Introduce the use of kobj_to_dev() helper function instead of open
> coding it with container_of()
> 
> The Coccinelle semantic patch used to make this change is as follows:
> 
> //<smpl>
> @@
> expression a;
> symbol kobj;
> @@
> - container_of(a, struct device, kobj)
> + kobj_to_dev(a)
> //</smpl>
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied.
