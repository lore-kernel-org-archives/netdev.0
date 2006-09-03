From: "Frank Schneider" <twodipu@hotmail.com>
Subject: Re: Loop detected - calling function from different
	modules
Date: Sun, 03 Sep 2006 13:20:40 +0200
Message-ID: <BAY101-F393A459AE607C79C6EE299AB320@phx.gbl>
References: <1157018266.3065.17.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, madwifi-devel@lists.sourceforge.net
Return-path: <madwifi-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1157018266.3065.17.camel@ux156>
To: johannes@sipsolutions.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=madwifi-devel>
List-Post: <mailto:madwifi-devel@lists.sourceforge.net>
List-Help: <mailto:madwifi-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/madwifi-devel>,
	<mailto:madwifi-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: madwifi-devel-bounces@lists.sourceforge.net
Errors-To: madwifi-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


hi Johannes,

as I told you I have done...
actually it was certainly nothing to do, I just assigned a my_function to 
the pointer of
hard_start_xmit  and i implemented my_function in ath_pci module  done my 
work
and then call the actuall function, which is exported btw, in wlan module 
which is sending data frame using  dev_queue_xmit(). and its working 
perfect..
but I just wonder one thing: in ath_pci module  net_device  *dev  is ath0 
interface
on the other hand wlan module  *dev is wifi0  interface (e.g.)
still is working well.

could anyone please give me a hints how  dev_queue_xmit() is using tx data 
queue (HAL_TX_QUEUE_DATA) to transmit data queue.
actually I want to use data queue for sending beacon frame, ofcourse not 
real implementation
but for an experiment, a research purpose..

R
/Frank




>From: Johannes Berg <johannes@sipsolutions.net>
>To: Frank Schneider <twodipu@hotmail.com>
>CC: netdev@vger.kernel.org
>Subject: Re: Loop detected - calling function from different modules
>Date: Thu, 31 Aug 2006 11:57:46 +0200
>
>Frank,
>
>
> > Any suggestions to do that please ?
>
>d80211 has a hardware definition struct that is registered by the driver
>and contains a callback that is called for each frame. This is the
>direction you should take as well:
>
>    hard_start_xmit (generic code)
>calls
>    hardware_xmit (your module code, e.g. in a struct wlan_device)
>
>johannes
>-
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
