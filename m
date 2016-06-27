From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/3] ss: Refactor inet_show_sock
Date: Mon, 27 Jun 2016 11:06:55 -0700
Message-ID: <20160627110655.474ef337@xeon-e3>
References: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
	<1466566706-1511-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35494 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbcF0SGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:06:41 -0400
Received: by mail-pf0-f175.google.com with SMTP id c2so64146531pfa.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:06:41 -0700 (PDT)
In-Reply-To: <1466566706-1511-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 20:38:24 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Extract parsing of sockstat and filter from inet_show_sock.
> While moving run_ssfilter into callers of inet_show_sock enable
> userspace filtering before the kill.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

I would add this but it has checkpatch style issues

WARNING: braces {} are not necessary for any arm of this statement
#65: FILE: misc/ss.c:2060:
+	if (s->local.family == AF_INET) {
[...]
 	} else {
[...]

WARNING: line over 80 characters
#80: FILE: misc/ss.c:2070:
+static int inet_show_sock(struct nlmsghdr *nlh, struct sockstat *s, int protocol)

ERROR: do not use assignment in if condition
#129: FILE: misc/ss.c:2295:
+	if ((err = inet_show_sock(h, &s, diag_arg->protocol)) < 0)
