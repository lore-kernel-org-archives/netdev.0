From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH] USB Pegasus driver - avoid a
 potential NULL pointer dereference.
Date: Mon, 30 Jul 2007 14:24:30 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0707301422160.13448@enigma.security.iitk.ac.in>
References: <200707290019.02591.jesper.juhl@gmail.com>
	<a781481a0707281637n5b123e4aib46c4e4b009b0018@mail.gmail.com>
	<9a8748490707281655u66e50bbfqba58687b579a85fe@mail.gmail.com>
	<200707291049.26619.oliver@neukum.org>
	<Pine.LNX.4.64.0707301053020.3113@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	Petko Manolov <petkan@users.sourceforge.net>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0707301053020.3113@bender.nucleusys.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On Mon, 30 Jul 2007, Petko Manolov wrote:

> On Sun, 29 Jul 2007, Oliver Neukum wrote:
> 
> > [...]
> > pegasus == NULL there would be a kernel bug. Silently ignoring
> > it, like the code now wants to do is bad. As the oops has never been
> > reported, I figure turning it into an explicit debugging test is overkill,
> > so removal seems to be the best option.
> 
> In the past urb->context was not guaranteed to be non-null for any
> asynchronous calls.  If this is not the case anymore then it should be removed
> from at least two more locations in the driver.
> 
> Attached you'll find the resulting patch.

Given Oliver's earlier comment, it looks okay to me. Thanks.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
