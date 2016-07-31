From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH 2/3] sctp_diag: export timer value only if it is active
Date: Sun, 31 Jul 2016 23:57:01 +0800
Message-ID: <CADvbK_f5a8xAELW28DT4iNVHzboSNN0xwXZBtdyKaDz=WTDJLg@mail.gmail.com>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
 <1469811580-32429-3-git-send-email-phil@nwl.cc> <20160729205113.GA2954@localhost.localdomain>
 <CADvbK_dWaMFz2f8GdavXuhyfiCxRmkT_8n9yHHNwSA3y_73WoA@mail.gmail.com>
 <ffdc7f0d-2c98-d63a-725a-01f738689907@gmail.com> <20160730175930.GE18872@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Phil Sutter <phil@nwl.cc>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Xin Long <lucien.xin@gmail.com>,
	David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34356 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbcGaP5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 11:57:05 -0400
Received: by mail-qk0-f181.google.com with SMTP id p186so1776539qkd.1
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2016 08:57:04 -0700 (PDT)
In-Reply-To: <20160730175930.GE18872@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> I'll look into this next week. One early question: Does the above mean
> we are printing the primary path's timer value for every assoc? If so,
> shouldn't we do that for just the EP or the primary path's assoc even?
>
Nope, we can't say "the primary path's assoc".

Every assoc has their own primary path, even these assocs belong
to one EP.  you can see it from (asoc->peer.primary_path).
