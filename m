From: xeb@mail.ru
Subject: =?koi8-r?Q?Re=3A_[PATCH_2/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 00:49:43 +0400
Message-ID: <E1OgkuF-00059M-00.xeb-mail-ru@f67.mail.ru>
References: <20100804102535.37bd94c4@nehalam>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f67.mail.ru ([217.69.129.106]:41029 "EHLO f67.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934570Ab0HDUtr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 16:49:47 -0400
In-Reply-To: <20100804102535.37bd94c4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Aug 2010 10:25:35 -0700 Stephen Hemminger <shemminger@vyatta.com> wrote:

> > +static DEFINE_RWLOCK(chan_lock);
> 
> A reader-writer lock is going to be slower than a spin lock
> (or RCU) for this. IF possible, could you use RCU?
> 

don't know, need to think about ...

