From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] ptp: add api to get ptp seq id and event type from
 skb
Date: Mon, 22 Oct 2012 13:36:22 +0200
Message-ID: <20121022113622.GD2285@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-5-git-send-email-mugunthanvnm@ti.com>
 <20121018025508.GD2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD6E6@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64482 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab2JVLgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:36:31 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so1373847wey.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:36:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD6E6@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:46:50AM +0000, N, Mugunthan V wrote:
> 
> Yeah agreed on static function too long, but this can be kept inside PTP
> frame work as every driver needs to use this API to parse the PTP events
> from the skb.

No, not every driver need this code. Otherwise it would already exist
in every driver.

Although some of the hardware does provide packet metadata for
matching time stamps to payloads, each hardware that I know of has its
own subtle differences in this regard.

Thanks,
Richard
