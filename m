From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2: ss - Disable stderr messages by default
Date: Wed, 18 Mar 2015 17:38:41 +0200
Message-ID: <20150318153841.GA1469@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:32906 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbCRPu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 11:50:26 -0400
Received: by lbnq5 with SMTP id q5so4697454lbn.0
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 08:50:25 -0700 (PDT)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id n12sm3459053lbg.31.2015.03.18.08.50.24
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 08:50:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

If use latest ss on older kernel (for example 3.0) there will be
RTNL errors printed and ss will use stats info from /proc because
kernel does not support some diag features. So would not it better
to do not print RTNL errors by default but only when special option was
specified - for example '-E' ?

Or at least add to man page that user can export PROC_ROOT variable to
ss to use /proc by default.

What do you think?

Thanks,
