From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 limits user-specified advertised speeds to one
Date: Wed, 10 Feb 2010 14:11:27 -0800
Message-ID: <1265839887.8125.39.camel@nseg_linux_HP1.broadcom.com>
References: <4B731F8A.20508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4766 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab0BJWWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 17:22:38 -0500
In-Reply-To: <4B731F8A.20508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2010-02-10 at 13:05 -0800, Vlad Yasevich wrote:
> Hi
> 
> A customer has noted that when attempting to change the advertised speeds
> setting on card using a bnx2 driver, the driver advertises either all available
> speeds or just one.  In other words, if a user attempts to set multiple
> advertised speeds,  the settings will not be honored.
> 
> Looking at the code in bnx2_set_settings, the checks for 10baseT and 100baseT
> make an assumption that the user provided only 1 speed setting.
> 
> e1000 and e1000e work correctly when the user specifies multiple advertised
> speeds.
> 
> Before attempting to fix this, I wanted to ask if there was a reason for the
> current functionality.
> 

Probably code to handle limitations in older versions of the ethtool
program.  There is no reason for it to be like this anymore.  I'll fix
this in my next patch set.  Thanks for reporting this.


