From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [iproute2 ] Fix compilation error of m_ipt.c with -Werror enabled
Date: Tue, 26 Feb 2013 11:23:45 -0800
Message-ID: <CAGK4HS_uu6RLBqHYrq181Jd0p7HCC=_W2ziQaeQQHhEWfazdNA@mail.gmail.com>
References: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:34632 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932566Ab3BZTXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:23:46 -0500
Received: by mail-oa0-f54.google.com with SMTP id n12so6029890oag.13
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:23:45 -0800 (PST)
In-Reply-To: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2013 11:12, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> Commit (5a650703d47e10aa386406c855eff5a593b2120b Makefile: make warnings into
> errors ) causes the following build error.
>

A similar error occurs for misc/ss.c

gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
-Wmissing-declarations -Wold-style-definition -O2
-I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\"
-DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE   -c -o ss.o ss.c
cc1: warnings being treated as errors
ss.c: In function 'user_ent_hash_build':
ss.c:300: error: ignoring return value of 'fscanf', declared with
attribute warn_unused_result
ss.c: In function 'get_slabstat':
ss.c:382: error: ignoring return value of 'fgets', declared with
attribute warn_unused_result
ss.c: In function 'init_service_resolver':
ss.c:506: error: ignoring return value of 'fgets', declared with
attribute warn_unused_result
---cut---

Not sure what is the best fix for this but can send a patch based on
suggestions.
I am using "Ubuntu 10.04.1 LTS" with ldd (GNU libc) 2.17.


Vijay
