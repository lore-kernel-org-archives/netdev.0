From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Re: [PATCH 4/14 linux-2.6.7-rc1] prism54: add
 support for avs header in
Date: Thu, 27 May 2004 15:31:00 -0400
Sender: prism54-devel-admin@prism54.org
Message-ID: <40B641F4.1040806@pobox.com>
References: <20040524083146.GE3330@ruslug.rutgers.edu> <40B631B3.4000902@pobox.com> <20040527191649.GT3330@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040527191649.GT3330@ruslug.rutgers.edu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Thu, May 27, 2004 at 02:21:39PM -0400, Jeff Garzik wrote:
> 
>>Luis R. Rodriguez wrote:
>>
>>>diff -u -r1.31 -r1.33
>>>--- linux-2.6.7-rc1/drivers/net/wireless/prism54/islpci_eth.c	18 Mar 2004 
>>>15:27:44 -0000	1.31
>>>+++ linux-2.6.7-rc1/drivers/net/wireless/prism54/islpci_eth.c	19 Mar 2004 
>>>23:03:58 -0000	1.33
>>>@@ -1,4 +1,4 @@
>>>-/*  $Header: /var/lib/cvs/prism54-ng/ksrc/islpci_eth.c,v 1.31 2004/03/18 
>>>15:27:44 ajfa Exp $
>>>+/*  $Header: /var/lib/cvs/prism54-ng/ksrc/islpci_eth.c,v 1.33 2004/03/19 
>>>23:03:58 ajfa Exp $
>>
>>
>>Please remove CVS substitions from your code, they cause endless patch 
>>rejects if I choose to apply (for example) 10 out of 14 patches.
> 
> 
> Will do. So if you get 
> 
> --- ksrc/islpci_eth.c
> +++ ksrc-new/islpci_eth.c
> 
> patches, that'll be OK? I substituted ksrc to
> linux-2.6.7-rc1/drivers/net/wireless/prism54 thinking that'll ease your
> job. Sorry for any inconvenience.


I think you misunderstand (and I apologize for causing the confusion).

It is _required_ that the patches include the full path in the header. 
You did this correctly:
--- linux-2.6.7-rc1/drivers/net/wireless/prism54/islpci_eth.c	18 Mar 
2004 15:27:44 -0000	1.31
+++ linux-2.6.7-rc1/drivers/net/wireless/prism54/islpci_eth.c	19 Mar 2004


I am referring to the CVS substitution variables embedded in your source 
code.  In this case $Header$.

However, consider what happens when I do:

1) apply patch #1
2) reject patch #2
3) attempt to apply patch #3

If each patch updates the $Header$, then patch #3 cannot be applied 
because patch(1) will reject it due to the now-incorrect $Header$ line.

The $Header$ _forces_ me to apply your patches in order, all or none.  I 
don't think you want that ;-)

	Jeff
