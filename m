From: "Ian Brown" <ianbrn@gmail.com>
Subject: A question about disabling sending redirects in IPV6 (versus IPV4)
Date: Wed, 26 Mar 2008 14:48:56 +0200
Message-ID: <d0383f90803260548h7a525ac0pc2f9b71539cd1ff2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:14684 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbYCZMs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:48:58 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4021076fgb.17
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 05:48:56 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a question regarding disabling sending redirects in IPV6 in the
linux kernel:

In include/linux/ipv6.h, I see a member called accept_redirects in
ipv6_devconf,
but there is no send_redirects member.

There is /proc/sys/net/ipv6/conf/all/accept_redirects but
I could not find /proc/sys/net/ipv6/conf/all/send_redirects.

(In IPV4 there is both /proc/sys/net/ipv4/conf/all/send_redirects and
/proc/sys/net/ipv4/conf/all/accept_redirects).

Is there some reason that there is no way (as far as I understand)
to disable sending redirects in IPV6 ? Why there is a way to do it in IPV4
and there is no way to do it in IPV6?

Regards,


Ian
