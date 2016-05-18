From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [1/1] net: pegasus: remove dead coding
Date: Wed, 18 May 2016 09:15:40 +0200
Message-ID: <1463555740.22748.0.camel@suse.com>
References: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
	 <20160518063024.GA29326@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Petko Manolov <petkan@nucleusys.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48366 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbcERHTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 03:19:10 -0400
In-Reply-To: <20160518063024.GA29326@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-17 at 23:30 -0700, Guenter Roeck wrote:
> On Wed, May 18, 2016 at 02:13:30AM +0200, Heinrich Schuchardt wrote:
> > (!count || count < 4) is always true.
> 
> Even if count >= 4 ?

The check for !count is redundant, though. Gcc, however,
will surely simplify the expression.

	Regards
		Oliver
