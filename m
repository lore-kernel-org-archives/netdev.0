From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2 tc: Print qdisc, stats, class, filter info to string rather
 than FILE
Date: Wed, 7 Jan 2015 23:53:31 +0200
Message-ID: <20150107215331.GA19197@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vadim4j@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:42888 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478AbbAGWDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 17:03:55 -0500
Received: by mail-lb0-f170.google.com with SMTP id 10so1866522lbg.15
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 14:03:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd like to make possible to generate plot info about class hierarchy
with qdisc, filters, stats info, but I see that all this staffs are
printed to 'FILE *fp' which makes this hard to implement and seems to me
that it should be changed to be printed to 'char *s' (memory safety
should be considered by asprintf or similar), so this is a big change
but all this is possible and I ready to do it, but before do it I'd like
to ask if this could be acceptable as idea.

BUT maybe someone can advise me easier solution ?

Regards,
