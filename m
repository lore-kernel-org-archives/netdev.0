From: Xiaochun Lu <xiaoclu@gmail.com>
Subject: Key change for TCP_MD5
Date: Tue, 1 Dec 2009 16:27:41 -0800
Message-ID: <911b679e0912011627q568132e8x655f109c75030725@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:47779 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbZLBAc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 19:32:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, ALL

This is regarding to TCP-MD5 option [RFC2385].  In current
implementation, only one md5 password is saved in the kernel and it
brings in the problem for changing key:  Changing key in the middle of
tcp session will break the session unless new md5 password is updated
at both ends at the same time (there is no window for key change).
Does anybody know any patches currently exist to address this issue? I
know rfc4808 is targeting to solve this issue. Does there any plan to
implement rfc4808 for linux?

Best Regards!


Shawn Lu
