From: rsa <ravi.mlists@gmail.com>
Subject: switching network namespace midway
Date: Tue, 23 Oct 2012 13:49:12 -0400
Message-ID: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49984 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab2JWRtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:49:14 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so2176906wey.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:49:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assuming I have a tunnel interface where two route lookups are done --
one for innter
packet and the other for outer -- do you see any issues in switching
the network
namespace prior to second route lookup (and restore to the original namespace
after the second lookup is done)?

If so, are there any other calls other than sk_change_net() needed?

thank you
rsa
