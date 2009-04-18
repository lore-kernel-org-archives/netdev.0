From: David Miller <davem@davemloft.net>
Subject: Re: What is lock_sock() before skb_free_datagram() for?
Date: Sat, 18 Apr 2009 02:08:37 -0700 (PDT)
Message-ID: <20090418.020837.106276006.davem@davemloft.net>
References: <200904181704.FDC21361.FQLOFHOOSVFtMJ@I-love.SAKURA.ne.jp>
	<20090418.013538.126788034.davem@davemloft.net>
	<200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200904181804.AHC13042.VHFFOOJOFLSQMt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 18 Apr 2009 18:04:24 +0900

> If it is harmful to call lock_sock() for protocols which don't
> support global socket memory accounting, I need to make
> lock_sock(sk);/release_ sock(sk); calls conditional.

Great, more complexity in the kernel for the sake of TOMOYO
:-(
