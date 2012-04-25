From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch v3, iproute2 version 3.2.0] Source mode for macvlan
 interface
Date: Wed, 25 Apr 2012 13:17:51 -0700
Message-ID: <20120425131751.46baa13b@nehalam.linuxnetplumber.net>
References: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stefan Gula <steweg@ynet.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56316 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758712Ab2DYUR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:17:58 -0400
In-Reply-To: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2012 14:14:00 +0100 (CET)
Stefan Gula <steweg@ynet.sk> wrote:

> From: Stefan Gula <steweg@gmail.com>
> 
> Adjusting iproute2 utility to support new macvlan link type mode
> called "source". Example of commands that can be applied:
>  ip link add link eth0 name macvlan0 type macvlan mode source
>  ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr flush
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>
> 

Please resubmit with man page, after the kernel header changes are in
Linus's tree (ie. 3.5 merge window).
