From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 21:28:38 +0900
Message-ID: <201204032128.JEG78136.JStMOHQOVFFFLO@I-love.SAKURA.ne.jp>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
	<1333448001-2507-4-git-send-email-pablo@netfilter.org>
	<201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
	<201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
	<20120403120900.GB6010@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52575 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab2DCM2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 08:28:41 -0400
In-Reply-To: <20120403120900.GB6010@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Indeed. The patch attached should fix this problem. Thanks.

It seems to me that the timeout object is associated with the "ct"
by successful nf_ct_timeout_ext_add() call. If yes,

 +err5:
 +	xt_ct_tg_timeout_put(ct);

will not be able to find the timeout object.
