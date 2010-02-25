From: "Octavian Purdila" <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v5 2/3] sysctl: add proc_do_large_bitmap
Date: Thu, 25 Feb 2010 11:46:35 +0200
Message-ID: <1267091195.12391.2.camel@Nokia-N900-42-11>
Reply-To: <opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>,
	"Linux Kernel Developers" <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Cong Wang" <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:24241 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753920Ab0BYJos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 04:44:48 -0500
Content-ID: <1267091194.12391.1.camel@Nokia-N900-42-11>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Hi,
>
> Still a small problem, if I do write(fd, "50000,50100", 12) I will
> get a return value of 11, which should mean 11 bytes are written,
> however, actually only the first 6 bytes are accepted.
>
> The rest looks better now.
>
> Or am I missing something here? :)
>

Will take a look at this a bit later today, thanks for testing.

In the meanwhile what are your thougths on the "1 2 3" issue, are you OK with accepting spaces as well as commas as separators?
