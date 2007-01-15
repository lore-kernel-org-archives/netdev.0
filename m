From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Mon, 15 Jan 2007 18:12:01 +0900
Message-ID: <45AB4561.8040400@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com> <4573E6FD.3030905@cj.jp.nec.com> <4574C14E.2060108@intel.com> <457E610D.4060908@cj.jp.nec.com> <45872EAC.7050501@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO200.gate.nec.co.jp ([210.143.35.50]:59149 "EHLO
	tyo200.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136AbXAOJQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 04:16:21 -0500
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id l0F9GIik026954
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 18:16:18 +0900 (JST)
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45872EAC.7050501@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

During the holiday season, I posted a patch that fixed this problem without
using spinlocks nor disabling interrupts.
  http://marc.theaimsgroup.com/?l=linux-netdev&m=116649413613845&w=2

With this patch applied, I confirmed that the system doesn't panic.
I think this patch can fix this problem.
Does this patch have problems.

I welcome any comments.

--
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
