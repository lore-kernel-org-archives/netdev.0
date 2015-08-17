From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 net-next] enic: add devcmd2
Date: Mon, 17 Aug 2015 15:38:32 -0700 (PDT)
Message-ID: <20150817.153832.1220000969996122058.davem@davemloft.net>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nalreddy@cisco.com, ssujith@cisco.com,
	benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbbHQWif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:38:35 -0400
In-Reply-To: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Sun, 16 Aug 2015 01:44:50 +0530

> This series adds new devcmd2 support. The first two patches are code
> refactoring.
> 
> devcmd is an interface for driver to communicate with fw/adaptor. It
> involves writing data to hardware registers and waiting for the result.
> This mechanism does not scale well. The queuing of "no wait" devcmds is
> done in firmware memory rather than on the host. Firmware memory is a
> rather more scarce and valuable resource than host memory. A devcmd storm
> from one vf can disrupt the service on other pf/vf. The lack of flow
> control allows for possible denial of server from one VM to another.
> Devcmd2 uses work queue to post the devcmds, just like tx work queue. This
> allows better flow control.

Series applied, thanks.
