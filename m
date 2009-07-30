From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [Bugme-new] [Bug 13856] New: sk_bound_dev_if should be set for
	a socket when using IP_MULITCAST_IF or IP_ADD_MEMBERSHIO
Date: Wed, 29 Jul 2009 19:46:12 -0500
Message-ID: <1248914772.13447.20.camel@merlyn>
References: <bug-13856-10286@http.bugzilla.kernel.org/>
	 <20090729125203.efbcb7ef.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, manlidj@hotmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:58057 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875AbZG3AqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 20:46:15 -0400
Received: by yxe26 with SMTP id 26so2011452yxe.4
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 17:46:15 -0700 (PDT)
In-Reply-To: <20090729125203.efbcb7ef.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         ReportedBy: manlidj@hotmail.com

> > Currently there is no way to tell which interface a multicast packet arrived on
> > except by using a raw socket and issuing the SO_BINDTODEVICE option which
> > forces the sk_bound_dev_if for the socket to be set.  

I thought the IP_PKTINFO cmsg was the usual way to do this.

--
John

