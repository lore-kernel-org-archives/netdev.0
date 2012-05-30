From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Strange latency spikes/TX network stalls on Sun Fire
 X4150(x86) and e1000e
Date: Wed, 30 May 2012 13:12:45 +0200
Message-ID: <1338376365.2760.157.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F31@saturn3.aculab.com>
	 <1338375895.2760.153.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61950 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab2E3LMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 07:12:50 -0400
Received: by bkcji2 with SMTP id ji2so3983299bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 04:12:49 -0700 (PDT)
In-Reply-To: <1338375895.2760.153.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 13:04 +0200, Eric Dumazet wrote:

> Please don't use lazy volatile.
> 
> Unless you really want Linus flames (and ours)
> 
> ACCESS_ONCE() is much cleaner.
> 

http://yarchive.net/comp/linux/ACCESS_ONCE.html
