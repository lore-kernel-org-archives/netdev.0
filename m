From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 13:10:04 -0500
Message-ID: <4AEF207C.9030002@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:58187 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427AbZKBSKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 13:10:06 -0500
Received: by ey-out-2122.google.com with SMTP id d26so455196eyd.19
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 10:10:10 -0800 (PST)
In-Reply-To: <4AE6E7C0.2050408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another style question:

+struct tcp_extend_values {
+	u8				cookie_bakery[TCP_COOKIE_MAX];
+	u8				cookie_plus;
+	u8				cookie_in_always:1,
+					cookie_out_never:1;
+};
+
+static inline struct tcp_extend_values *tcp_xv(const struct request_values *rvp)
+{
+	return (struct tcp_extend_values *)rvp;
+}

Some examples have "struct request_values" as the first element, others
don't.  I started with it, and then removed it (as essentially nil).

Is there a preference?
