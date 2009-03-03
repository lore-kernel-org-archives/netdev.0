From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sctp: fix kernel panic with ERROR chunk containing
 too many error causes
Date: Mon, 02 Mar 2009 22:29:08 -0800 (PST)
Message-ID: <20090302.222908.180790085.davem@davemloft.net>
References: <1236012411-17841-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752702AbZCCG30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:29:26 -0500
In-Reply-To: <1236012411-17841-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon,  2 Mar 2009 11:46:51 -0500

> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> If ERROR chunk is received with too many error causes in ESTABLISHED
> state, the kernel get panic.
> 
> This is because sctp limit the max length of cmds to 14, but while
> ERROR chunk is received, one error cause will add around 2 cmds by
> sctp_add_cmd_sf(). So many error causes will fill the limit of cmds
> and panic.
> 
> This patch fixed the problem.
> 
> This bug can be test by SCTP Conformance Test Suite
> <http://networktest.sourceforge.net/>.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
