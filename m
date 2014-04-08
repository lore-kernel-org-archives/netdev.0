From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: [PATCH] phylib: export phy_suspend and phy_resume
Date: Tue, 8 Apr 2014 19:07:41 +0200
Message-ID: <20140408170741.GA4793@gmail.com>
References: <20140408071101.GA14453@gmail.com>
 <20140408.122953.1708326631498329706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:59222 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131AbaDHRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:08:23 -0400
Received: by mail-bk0-f49.google.com with SMTP id my13so802353bkb.8
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 10:08:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140408.122953.1708326631498329706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2014 at 12:29:53PM -0400, David Miller wrote:
> From: Tobias Waldekranz <tobias@waldekranz.com>
> Date: Tue, 8 Apr 2014 09:11:01 +0200
> 
> > These functions are exported in include/linux/phy.h but the symbol
> > exports where missing.
> > 
> > Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
> 
> Because they are only used in places where module exports are unnecessary.
> Presence in foo.h does not automatically mean the symbol should be
> exported to modules.
> 
> If you come up with a use case that requires the module export, submit
> it along with a patch like this.
> 
> But for now I'm not applying this, sorry.

Further investigation revealed that I was actually looking for
phy_start/stop. Sorry about the noise.

-- 
Thanks
 - wkz
