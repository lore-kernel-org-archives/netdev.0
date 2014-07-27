From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH] kernel-doc compliant documentation for net_device
Date: Sun, 27 Jul 2014 09:17:18 -0700
Message-ID: <53D5260E.9060507@infradead.org>
References: <1405870622-17222-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=y
Content-Transfer-Encoding: 7bit
To: Karoly Kemeny <karoly.kemeny@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, trivial@kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1405870622-17222-1-git-send-email-karoly.kemeny@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/14 08:37, Karoly Kemeny wrote:
> Net_device is a vast and important structure, but it has no kernel-doc compliant
> documentation. this patch extracts the comments from the structure to clean it up,
> and let the scripts extract documentation from it, i know it's big, but it is just
> reordering of comments into the appropriate form.
> 
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> ---
>  include/linux/netdevice.h | 367 +++++++++++++++++++++++++++++-----------------
>  1 file changed, 232 insertions(+), 135 deletions(-)


[third attempt to reply without message body being truncated]


a.  The struct comments should begin with a line like this:
/**
to indicated kernel-doc notation.

b.  Blank lines are not allowed in kernel-doc comments. They should instead be:
 *

Warning(..//include/linux/netdevice.h:1277): bad line:  
Warning(..//include/linux/netdevice.h:1281): bad line:  

c.  A few fields in the struct don't have any comments for them:

Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'name_hlist'
Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'state'
Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'dev_list'
Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'napi_list'
Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'unreg_list'
Warning(..//include/linux/netdevice.h:1661): No description found for parameter 'close_list'


d.  Don't introduce lines that have trailing whitespace:

Warning: trailing whitespace in lines 1237,1252,1255,1257,1260,1266,1268,1274,1277,1281,1284,1295,1330,1332,1334,1336,1351,1353,1358,1367,1382,1389,1392,1404,1407,1408,1451,1458,1463,1466,1481,1504,1508,1525,1584,1588,1591,1623,1628 of include/linux/netdevice.h


e.  I think that this is a good patch idea, so please fix these minor issues
and resubmit the patch.

Thanks.

-- 
~Randy
