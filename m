From: David Miller <davem@davemloft.net>
Subject: Re: hyperv: fix apparent cut-n-paste error in send path teardown
Date: Mon, 16 Jun 2014 21:36:41 -0700 (PDT)
Message-ID: <20140616.213641.1511269104828196487.davem@davemloft.net>
References: <20140616205902.GA7331@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbaFQEgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:36:41 -0400
In-Reply-To: <20140616205902.GA7331@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 16 Jun 2014 16:59:02 -0400

> c25aaf814a63: "hyperv: Enable sendbuf mechanism on the send path" added
> some teardown code that looks like it was copied from the recieve path
> above, but missed a variable name replacement.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Good catch, applied, thanks Dave.
