From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: echo > 0 .../disable_ipv6 broken in 2.6.37-rc4
Date: Sun, 5 Dec 2010 16:33:46 -0800
Message-ID: <AANLkTin4hO63J4thByJeG2SiGHn9ZqsbWKy1p_TEfeu_@mail.gmail.com>
References: <m17hfnlpe1.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>,
	Mahesh Kelkar <maheshkelkar@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:16070 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab0LFAeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 19:34:09 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id oB60Y8QK002172
	for <netdev@vger.kernel.org>; Sun, 5 Dec 2010 16:34:08 -0800
Received: from iwn6 (iwn6.prod.google.com [10.241.68.70])
	by kpbe19.cbf.corp.google.com with ESMTP id oB60XXre009518
	for <netdev@vger.kernel.org>; Sun, 5 Dec 2010 16:34:07 -0800
Received: by iwn6 with SMTP id 6so2820866iwn.33
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 16:34:07 -0800 (PST)
In-Reply-To: <m17hfnlpe1.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 5, 2010 at 4:24 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> In 2.6.37-rc4 ipv6 can be disabled not enabled.
> The last kernel I have tested and know this works on is 2.6.33.

I'm pretty sure I could successfully re-enable IPv6 on non-loopback
interfaces (wlan0, eth0) on net-2.6 pulled a little after 2.6.37-rc1.
I didn't try lo though. Does re-enabling IPv6 on a "real" interface
still work?
