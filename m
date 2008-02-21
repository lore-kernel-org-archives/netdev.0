From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:14:33 -0800
Message-ID: <1203588873.20345.25.camel@brick>
References: <1203586467.20345.14.camel@brick>
	 <20080221.015743.222059206.davem@davemloft.net>
	 <1203588079.20345.15.camel@brick>
	 <20080221.020554.259219477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:2573 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbYBUKOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:14:18 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4428713wah.23
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 02:14:17 -0800 (PST)
In-Reply-To: <20080221.020554.259219477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 02:05 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Thu, 21 Feb 2008 02:01:19 -0800
> 
> > In this case, it's being passed to a debugfs create function, could it
> > instead use sysfs_format_mac?
> 
> Just assigning print_mac() to a local variable then passing that to
> debugfs_create_dir() will make the warning go away.

Well, in this case I'd suggest either reverting the __pure annotation
or just ignoring the warning.

Harvey

