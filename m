From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 12:06:04 +0100
Message-ID: <20120214110604.GI32155@v3-1054>
References: <201202132253.16496.jdelvare@suse.de>
 <22039.1329171191@death.nxdomain>
 <201202141122.10705.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slnx.de ([79.140.41.54]:51451 "EHLO v3-1054.slnx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756592Ab2BNLDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 06:03:39 -0500
Content-Disposition: inline
In-Reply-To: <201202141122.10705.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 11:22:10AM +0100, Jean Delvare wrote:
> 
> Well I am still curious why the 3c59x driver has such slow polling when 
> other drivers I have been testing are able to report almost instantly 
> when I remove a network cable. Could it be that other network chips 
> generate an interrupt on cable removal and the 3com chips do not?
> 

Yes, at least some of the supported chips do not generate an interrupt
on cable removal, so we have to check for this with a timer.
