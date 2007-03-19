From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [SK_BUFF]: Adjust the zeroing up to tail in
 __alloc_skb too
Date: Mon, 19 Mar 2007 12:16:22 -0700 (PDT)
Message-ID: <20070319.121622.55507267.davem@davemloft.net>
References: <20070319135030.GE17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751199AbXCSTQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 15:16:22 -0400
In-Reply-To: <20070319135030.GE17811@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 19 Mar 2007 10:50:30 -0300

> Hi David,
> 
> 	Please pull from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22

Pulled, thanks Arnaldo.

Can you please verify the white-space in your patches in the future?
I have a ton of whitespace warnings from GIT to fix up as I'm rebasing
the net-2.6.22 tree.  The following "pcheck" script (which I've
probably posted like 10 or more times) works great for this.

Unfortunately, when you "git commit" stuff GIT doesn't do whitespace
damange checking by default, only when you are importing patches or
similar :-/

#!/bin/sh
set -x
git apply --check --whitespace=error-all $1


