From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/2] [net] af_unix: return data from multiple SKBs
 on recv() with MSG_PEEK flag
Date: Tue, 29 Sep 2015 13:47:23 -0700 (PDT)
Message-ID: <20150929.134723.1384484811363656325.davem@davemloft.net>
References: <20150924.121459.1016780653505420756.davem@davemloft.net>
	<1443307843-16880-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbbI2UrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 16:47:25 -0400
In-Reply-To: <1443307843-16880-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Sat, 26 Sep 2015 18:50:41 -0400

> This patch set implements a bugfix for kernel.org bugzilla #12323, allowing
> MSG_PEEK to return all queued data on the unix domain socket, not just the
> data contained in a single SKB. 
> 
> This is the v3 version of this patch, which includes a suggested modification
> by Eric Dumazet to convert the unix_sk() conversion macro to a static inline
> function. These patches are independent and can be applied separately.
> 
> This set was tested over a 24-hour period, utilizing a loop continually 
> executing the bugzilla issue attached python code. It was instrumented with
> a pr_err_once() ([   13.798683] unix: went there at least one time).
> 
> v2->v3:
>  - Added Eric Dumazet's suggestion for #define to static inline
>  - Fixed an issue calling unix_state_lock() with an invalid argument
> 
> v3->v4:
>  - Eliminated an XXX comment
>  - Changed from goto unlock to explicit unix_state_unlock() and break

Series applied, thanks.
