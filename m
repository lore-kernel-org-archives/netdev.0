From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [BUG] Deadlock on sk->sk_lock.slock
Date: Wed, 05 Mar 2014 09:34:31 -0800
Message-ID: <1394040871.27473.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
	 <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <771471B8871B5044A6CA7CCD9C26EEE10117E265C985@xmail2.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lars Persson <lars.persson@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33357 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbaCEReh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 12:34:37 -0500
Received: by mail-pa0-f43.google.com with SMTP id bj1so1388954pad.30
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 09:34:37 -0800 (PST)
In-Reply-To: <771471B8871B5044A6CA7CCD9C26EEE10117E265C985@xmail2.se.axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-05 at 16:01 +0100, Lars Persson wrote:
> Thanks, this patch has survived a 24 hour test session. I will now
> start a test with the new sock_release_ownership patch.

Thanks a lot Lars !
