From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169+NAPI soft lockup
Date: Wed, 10 May 2006 23:50:04 +0200
Message-ID: <20060510215004.GA25395@electric-eye.fr.zoreil.com>
References: <4460B8DC.9080105@liv.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:65498 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965030AbWEJVvT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 17:51:19 -0400
To: Richard Gregory <R.Gregory@liverpool.ac.uk>
Content-Disposition: inline
In-Reply-To: <4460B8DC.9080105@liv.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Gregory <R.Gregory@liverpool.ac.uk> :
[...]
> # locked in 1 min. Output in bug5.txt
> $ for i in `seq 0 26` ; do cat /dev/md1 > /dev/tcp/linuxbox/9 &
> $ cat /dev/md0 > /dev/tcp/localhost/9

Can you replace /dev/tcp/foo with a simple /dev/null and send the output
of 'vmstat 1' during 2 minutes of test ?

A few seconds of 'vmstat 1' during a simple dd from /dev/md0
(resp. /dev/md1) would be welcome too.

-- 
Ueimor
