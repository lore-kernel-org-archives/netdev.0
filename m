From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 21:23:35 +0900
Message-ID: <200904182123.HFF13509.MVSJtQHFLFOFOO@I-love.SAKURA.ne.jp>
References: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
	<20090418.013538.126788034.davem@davemloft.net>
	<200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
	<20090418.020837.106276006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:64708 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbZDRMXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 08:23:39 -0400
In-Reply-To: <20090418.020837.106276006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > If it is harmful to call lock_sock() for protocols which don't
> > support global socket memory accounting, I need to make
> > lock_sock(sk);/release_ sock(sk); calls conditional.
> 
> Great, more complexity in the kernel for the sake of TOMOYO
> :-(
> 
You meant that I should leave lock_sock(sk);/release_sock(sk); calls
unconditional?
This error path is not frequently called. If there are no problems but
performance, I'll leave them unconditional.
