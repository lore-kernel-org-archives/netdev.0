From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH -stable] multiple backports requested
Date: Fri, 13 Nov 2015 15:13:11 -0500
Message-ID: <1447445591.2645.17.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34492 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbbKMUNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 15:13:14 -0500
Received: by qkfo3 with SMTP id o3so58760213qkf.1
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 12:13:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, could you please add the following backports?

For the 3.14.y stable queue:
	commit 77751427a1ff25b27d47a4c36b12c3c8667855ac
	ipv6: addrconf: validate new MTU before applying it
	This addresses CVE-2015-0272

	commit 74e98eb085889b0d2d4908f59f6e00026063014f
	RDS: verify the underlying transport exists before creating a connection
	This addresses CVE-2015-6937

For the 4.1.y stable queue:

	commit 74e98eb085889b0d2d4908f59f6e00026063014f
	RDS: verify the underlying transport exists before creating a connection
	This addresses CVE-2015-6937

Thanks!
