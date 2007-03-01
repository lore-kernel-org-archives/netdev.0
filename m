From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Network access fails unless tcpdump is running?
Date: Thu, 1 Mar 2007 15:13:08 -0500
Message-ID: <20070301201307.GC3199@gospo.rdu.redhat.com>
References: <87y7mg4vm7.fsf@corps.glidepath.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc D Ronell <mronell@alumni.upenn.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965560AbXCAUNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 15:13:36 -0500
Content-Disposition: inline
In-Reply-To: <87y7mg4vm7.fsf@corps.glidepath.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 02:22:24PM -0500, Marc D Ronell wrote:
> 
> Hi,
> 
> I can not ping a remote host successfully unless I have "tcpdump -i
> eth0" running, in which case, my network access works fine.  

Interesting that when your interface is in promiscious mode it works
fine, but otherwise it doesn't.  Do you have all of your iptables rules
cleared?

> I am  running Debian etch on  a Dell Inspiron e1505  laptop.  The eth0
> address  is static  on my  local LAN.   Once tcpdump  is  running, the
> laptop can access the network with no problems.

What networking hardware is on that laptop?  Can you post the complete
output of `ethtool -i eth0` and the network device info from the output
of `lcpci -vvv`?
