From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2: suppress rtnl errors by default
Date: Tue, 24 Mar 2015 10:40:07 +0200
Message-ID: <20150324084007.GA4382@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33731 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbCXIwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 04:52:05 -0400
Received: by lbcmq2 with SMTP id mq2so25763409lbc.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 01:52:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I already sent similar email about such questions but I will try again,
may be it was lost.

So when the up to date version of iproute2 is used on the older kernel
it might print the rtnl errors which is mostly related to case when old
kernel does not support some rtnl flags/types/attrs, so would not it be
better to suppress such messages by default but add a special command
line option which will enable them ?

Thanks,
Vadim Kochan
