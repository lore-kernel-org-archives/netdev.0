From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net v2 5/9] bridge: Fix the way to check if a local fdb
 entry can be deleted
Date: Fri, 20 Dec 2013 17:02:56 +0900
Message-ID: <1387526576.3475.5.camel@ubuntu-vm-makita>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1387281821-21342-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <52B09DB2.7040700@redhat.com> <1387341972.3563.71.camel@ubuntu-vm-makita>
	 <52B1D9E6.7020201@redhat.com> <1387455834.4084.47.camel@ubuntu-vm-makita>
	 <20131219093921.449c5d62@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, "David S . Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:57542 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab3LTIDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 03:03:07 -0500
In-Reply-To: <20131219093921.449c5d62@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 09:39 -0800, Stephen Hemminger wrote:
...
> Could we make up as set of test case scripts to validate these changes.
> Now that FDB table can be manipulated by iproute tools, should be possible
> to have set of cases for validation.

Thank you for your suggestion.
Maybe is it enough to make some test of port attach/detach and confirm
that data/control plane doesn't result in any inconsistency or odd
situation by tcpdump/bridge commands?

Thanks,
Toshiaki Makita
