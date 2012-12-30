From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] team: add ethtool support
Date: Sun, 30 Dec 2012 00:30:24 -0200
Message-ID: <20121230023024.GC2077@obelix.rh>
References: <1356830366-991-1-git-send-email-fbl@redhat.com>
 <20121229172945.25a09fc8@nehalam.linuxnetplumber.net>
 <20121230014403.GA2077@obelix.rh>
 <20121229.180930.2054437059250829691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab2L3Cal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2012 21:30:41 -0500
Content-Disposition: inline
In-Reply-To: <20121229.180930.2054437059250829691.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 06:09:30PM -0800, David Miller wrote:
> From: Flavio Leitner <fbl@redhat.com>
> Date: Sat, 29 Dec 2012 23:44:03 -0200
> 
> > Right, but those statistics can be device specific as well.  The tg3 and bnx2, for
> > instance, do the same reporting [rx|tx]_bytes|octets. 
> 
> Because those ARE PER QUEUE in multiqueue configurations, and thus
> device specific.
> 
> There is no reason to report the bare single-queue generic
> netdevice stats via ethtool.

Alright, I will post another version without the statistics.
please, drop this one.
thanks,
-- 
fbl
