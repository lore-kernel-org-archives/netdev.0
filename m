From: Tom Herbert <tom@herbertland.com>
Subject: Has RFC4821 been implemented?
Date: Fri, 22 Jan 2016 11:39:50 -0800
Message-ID: <CALx6S36MOrJpLQ0QU8vERHc4yW-dDzrqURStnnscVS6-0WiAKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36822 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcAVTjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 14:39:51 -0500
Received: by mail-io0-f169.google.com with SMTP id g73so100724914ioe.3
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 11:39:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This came up on in one of the IETF mailing lists in the context that
PMTUD doesn't really work on the Internet so  PLPMTUD is the way to
go. Looking at the code I only see inet_csk_update_pmtu called from
ICMP PTB error. I am missing something?

Thanks,
Tom
