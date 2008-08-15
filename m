From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] pkt_sched: Fix unlocking in tc_ctl_tfilter()
Date: Fri, 15 Aug 2008 09:38:15 +0300
Message-ID: <200808150938.15275.denys@visp.net.lb>
References: <20080814224129.GA2517@ami.dom.local> <200808150156.49541.denys@visp.net.lb> <20080814232708.GB2517@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:37893 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbYHOGjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:39:19 -0400
In-Reply-To: <20080814232708.GB2517@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 August 2008, Jarek Poplawski wrote:
> pkt_sched: Fix unlocking in tc_ctl_tfilter()
>
> Fix a bug with spin_lock_bh() inserted instead of spin_unlock_bh() by
> some recent patch.
>
>

Thats fixed the problem, tested on two loaded servers. Thanks a lot!
