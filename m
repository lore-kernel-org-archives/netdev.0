From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/6] drivers: net: ethernet: davinci_cpdma: add clear
 api for statistics interrupt
Date: Mon, 22 Oct 2012 13:31:04 +0200
Message-ID: <20121022113103.GC2285@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-3-git-send-email-mugunthanvnm@ti.com>
 <20121018024808.GB2867@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293E9FD6BB@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63526 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab2JVLbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 07:31:14 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2349736wib.1
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 04:31:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9FD6BB@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 22, 2012 at 10:42:26AM +0000, N, Mugunthan V wrote:
> 
> What happens when Hardware timestamps are used?

They are not being used.

> It will be good to
> notify the application immediately using the interrupts instead of
> using workqueue which can delay the event in hardware for max about
> HZ*8.

Yes, it would make sense to use the interrupt in that case, but I did
not see any code supporting external events. In any case, I still want
to handle the overflow in the same way as in the other PHC drivers,
for the sake of consistency, and to avoid wasting CPU time "in
interrupt" with silly counter overflow code.

Thanks,
Richard
