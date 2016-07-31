From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/3] sctp: Export struct sctp_info to userspace
Date: Sun, 31 Jul 2016 14:18:24 -0700
Message-ID: <20160731141824.30785573@xeon-e3>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
	<1469811580-32429-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35670 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbcGaVTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 17:19:06 -0400
Received: by mail-pa0-f48.google.com with SMTP id iw10so46008887pac.2
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2016 14:18:13 -0700 (PDT)
In-Reply-To: <1469811580-32429-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Jul 2016 18:59:38 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This is required to correctly interpret INET_DIAG_INFO messages exported
> by sctp_diag module.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

You need to add sctp.h to include/linux/Kbuild to get it exported correctly
