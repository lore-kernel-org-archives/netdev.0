From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: constify attribute_group
	structures.
Date: Thu, 29 Jun 2017 15:50:04 -0400 (EDT)
Message-ID: <20170629.155004.847683681702714728.davem@davemloft.net>
References: <dc7089d0bab72d77ef4819b7d46c8cf88cae6588.1498734476.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <dc7089d0bab72d77ef4819b7d46c8cf88cae6588.1498734476.git.arvind.yadav.cs@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 29 Jun 2017 16:39:38 +0530

> attribute_groups are not supposed to change at runtime. All functions
> working with attribute_groups provided by <linux/sysfs.h> work with const
> attribute_group. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>    2645	    896	      0	   3541	    dd5	net/bridge/br_sysfs_br.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>    2701	    832	      0	   3533	    dcd	net/bridge/br_sysfs_br.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
