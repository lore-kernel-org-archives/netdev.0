From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] hyperv: netvsc: Neaten netvsc_send_pkt by using a
 temporary
Date: Wed, 02 Aug 2017 10:36:20 -0700 (PDT)
Message-ID: <20170802.103620.153488150214136568.davem@davemloft.net>
References: <280adfa19cb240fd843102215d423f9a2e724ff2.1501522035.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <280adfa19cb240fd843102215d423f9a2e724ff2.1501522035.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 31 Jul 2017 10:30:54 -0700

> Repeated dereference of nvmsg.msg.v1_msg.send_rndis_pkt can be
> shortened by using a temporary.  Do so.
> 
> No change in object code.
> 
> Miscellanea:
> 
> o Use * const for rpkt and nvchan
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next.
