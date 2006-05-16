From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/* (again)
Date: Tue, 16 May 2006 13:01:45 +0200
Message-ID: <200605161301.46030.netdev@axxeo.de>
References: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	grsecurity@grsecurity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:44204 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1751771AbWEPLBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 07:01:32 -0400
To: Chris Boot <bootc@bootc.net>
In-Reply-To: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris,

here are some steps to narrow it down.

1. try the latest kernel first (2.6.16.16). This BUG should be fixed there.
2. try without grsecurity patch 
3. if it still persists:

	Please provide more information about your setup before
	submitting a bug.

	lspci -vvv and your .config would be the minimum
	some ethtool outputs (ethtool -k ethX) would help here.

4. If you like to have it resolved very fast, please try git-bisect.
    This can take a lot of time (several recompiles and reboots needed!).

Happy Bug hunting!

Regards

Ingo Oeser
