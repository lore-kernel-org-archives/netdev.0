From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 15:16:31 +0200
Message-ID: <20110522131630.GA3156@jirka.orion>
References: <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion>
 <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com>
 <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com>
 <20110522062915.GA2611@jirka.orion>
 <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com>
 <20110522093758.GC2611@jirka.orion>
 <BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954Ab1EVNRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 09:17:00 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<snip>

>
>I know the current software emulation doesn't strip the vlan headers,
>but I want to know in what way you fix the current misuse of
>vlan_check_reorder_header(). If you emulation what the HW does
>exactly, I am afraid more work are needed. IMHO, this way is more
>dangerous than just a revert for this bugfix cycle.

Looking at this. Will follow-up soon.

>
>-- 
>Regards,
>Changli Gao(xiaosuo@gmail.com)
