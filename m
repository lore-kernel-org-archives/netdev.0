From: jamal <hadi@cyberus.ca>
Subject: Re: [Patch 9/9] Generic netlink interface for delay accounting
Date: Mon, 13 Mar 2006 21:29:09 -0500
Message-ID: <1142303349.5219.19.camel@jzny2>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297791.5858.31.camel@elinux04.optonline.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752103AbWCNC3M@vger.kernel.org>
To: nagar@watson.ibm.com
In-Reply-To: <1142297791.5858.31.camel@elinux04.optonline.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-13-03 at 19:56 -0500, Shailabh Nagar wrote:
> delayacct-genetlink.patch
> 
> Create a generic netlink interface (NETLINK_GENERIC family), 
> called "taskstats", for getting delay and cpu statistics of 
> tasks and thread groups during their lifetime and when they exit. 
> 
> Comments addressed (all in response to Jamal)
> 

Note, you are still not following the standard scheme of doing things.
Example: using command = GET and the message carrying the TGID to note
which TGID is of interest. Instead you have command = TGID.

cheers,
jamal
