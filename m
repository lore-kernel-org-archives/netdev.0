From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 00/17] sky2 update for 2.6.22
Date: Wed, 09 May 2007 00:16:48 -0400
Message-ID: <46414B30.6050603@garzik.org>
References: <20070509034949.624934448@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40390 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967460AbXEIEQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 00:16:51 -0400
In-Reply-To: <20070509034949.624934448@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Patches are against netdev-2.6 upstream code branch.
> 
> This includes a several bug fixes, and code cleanup to use standard
> functions. There are a couple of PCI changes. One bug fix, and moving
> common code in PCI base.

The standard development process is:

	* new code gets pushed to me during 2.6.X-rc
	* that code is auto-propagated to akpm's -mm tree for
	  additional exposure
	* merge window opens
	* I push upstream

That ensures code gets at least /some/ additional review, testing, 
"settling" time.

This is a late date to be expecting stuff to be pushed straight into 2.6.22.

Additionally, the rule for creating patches is:  diff against latest 
vanilla linux-2.6.git tree, unless dependencies exist in netdev.  After 
the merge window opens, #upstream is often empty or even a bit behind 
upstream, since Linus pulls that.

	Jeff



