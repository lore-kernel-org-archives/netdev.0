From: Dave Jones <davej@redhat.com>
Subject: Re: linked list corruption/use after free on bonding unload.
Date: Tue, 9 Apr 2013 15:42:51 -0400
Message-ID: <20130409194251.GA8166@redhat.com>
References: <20130409185002.GA3784@redhat.com>
 <20130409.153831.1917719597139130549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934655Ab3DITmz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 15:42:55 -0400
Content-Disposition: inline
In-Reply-To: <20130409.153831.1917719597139130549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 03:38:31PM -0400, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Tue, 9 Apr 2013 14:50:02 -0400
 > 
 > > Just hit this while doing a load/unload test of various modules.
 > > No bonding configuration had been set up, just the module loaded.
 > 
 > What tree?

v3.9-rc6-13-gf011a08

 > We recently had to revert a bonding "fix" and implement it differently.
 > So Linus's tree could cause this oops on bonding unload but 'net'
 > won't.

ah, sounds promising. I'll retest when your next push lands.

thanks,
	Dave
