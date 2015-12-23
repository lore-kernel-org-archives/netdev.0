From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 3/5] cxgb4: add dcb info node in debugfs
Date: Wed, 23 Dec 2015 10:37:52 +0530
Message-ID: <20151223050750.GA23659@hari-Latitude-E5550>
References: <1450682170-7106-1-git-send-email-hariprasad@chelsio.com>
 <1450682170-7106-4-git-send-email-hariprasad@chelsio.com>
 <CAJ3xEMjctGauyRjCKLV+wACkzDC5xF8J9khdhCm+YZXuEafU5Q@mail.gmail.com>
 <20151222.154552.1762036210080562354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org, leedom@chelsio.com,
	nirranjan@chelsio.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:40070 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751633AbbLWFIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 00:08:04 -0500
Content-Disposition: inline
In-Reply-To: <20151222.154552.1762036210080562354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 15:45:52 -0500, David Miller wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Mon, 21 Dec 2015 09:33:22 +0200
> 
> > On Mon, Dec 21, 2015 at 9:16 AM, Hariprasad Shenai
> > <hariprasad@chelsio.com> wrote:
> >> Add new /sys/kernel/debug/cxgb4/*/dcb_info node to dump out
> >> various Data Center Bridging information.
> > 
> > why? what's wrong with using the lldp tool for that purpose?
> 
> Agreed, and I don't like your explanation.
> 
> Even if you are using firmware managed DCB, the lldp tool should be
> usable for querying.
> 
> People need to stop putting so much crap into debugfs, it's a serious
> pet peeve of mine.
> 
> Every piece of driver unique interface crap you put into debugfs is a
> _HARDSHIP_ for the user.  Because they have to learn a unique way to
> do X in every driver that tries to export the same kind of
> functionality.

Will drop this from the series for now and send V2 for the same.
Will send a separate series for adding lldptool support for firmware
managed DCB.
