From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 net-next] ptp: dynamic allocation of PHC char devices
Date: Fri, 12 Apr 2013 19:48:02 +0200
Message-ID: <20130412174802.GA6902@netboy>
References: <bb5ff20a9968a810e6f827921e56fc8fc8fededf.1365764133.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:38870 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab3DLRsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 13:48:13 -0400
Received: by mail-ee0-f52.google.com with SMTP id d17so1363637eek.39
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 10:48:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bb5ff20a9968a810e6f827921e56fc8fc8fededf.1365764133.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 12:56:15PM +0200, Jiri Benc wrote:
> As network adapters supporting PTP are becoming more common, machines with
> many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
> char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
> the ptp driver allocate the char devices dynamically.
> 
> Tested with 28 PHCs, removing and re-adding some of them.
> 
> Thanks to Ben Hutchings for advice leading to simpler and cleaner patch.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
