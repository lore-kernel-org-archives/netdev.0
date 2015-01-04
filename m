From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/3] ss: Unify packet stats output from
 netlink and proc
Date: Sun, 4 Jan 2015 10:30:08 -0800
Message-ID: <20150104103008.1648dcb8@urahara>
References: <1420392055-4754-1-git-send-email-vadim4j@gmail.com>
	<1420392055-4754-3-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:62140 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbbADSaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 13:30:19 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so27166933pab.20
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 10:30:18 -0800 (PST)
In-Reply-To: <1420392055-4754-3-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  4 Jan 2015 19:20:54 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> +struct pktstat {
> +	int type;
> +	int prot;
> +	int iface;
> +	int state;
> +	int rq;
> +	int uid;
> +	int ino;
> +};

Rather than copying the original data types, this structure should use the
correct types that already exist. 
For example: type is pdiag_type which is __u8 therefore it should be __u8 or uint8_t.

Likewise uid should be uid_t etc.
