From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS)
 support
Date: Tue, 22 Dec 2015 18:01:54 +0100
Message-ID: <20151222170154.GA1940@localhost.localdomain>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
 <1450647991-13736-4-git-send-email-saeedm@mellanox.com>
 <20151221091509.GA2297@localhost.localdomain>
 <CALzJLG_YKG+mO+H9Lv6kgMoYRdBjUBWQiAPzhehTe0vNaLmOwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33710 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754249AbbLVRB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 12:01:59 -0500
Received: by mail-wm0-f54.google.com with SMTP id p187so115906516wmp.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 09:01:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALzJLG_YKG+mO+H9Lv6kgMoYRdBjUBWQiAPzhehTe0vNaLmOwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 12:00:52PM +0200, Saeed Mahameed wrote:
> Ok, but what will happen if somehow tstamp->overflow_period is zero ?
> the work will run too rapidly.
> don't we need to have protection against such case.

Why not return an error in that case?

Thanks,
Richard
