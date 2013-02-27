From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 ] Fix compilation error of m_ipt.c with -Werror
 enabled
Date: Tue, 26 Feb 2013 17:36:58 -0800
Message-ID: <20130226173658.74b51f2d@nehalam.linuxnetplumber.net>
References: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:44418 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759286Ab3B0BhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 20:37:25 -0500
Received: by mail-pb0-f50.google.com with SMTP id up1so26821pbc.9
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 17:37:24 -0800 (PST)
In-Reply-To: <1361905927-31534-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2013 11:12:07 -0800
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> Commit (5a650703d47e10aa386406c855eff5a593b2120b Makefile: make warnings into
> errors ) causes the following build error.
> 
> gcc -Wall -Wstrict-prototypes -Werror -Wmissing-prototypes
> -Wmissing-declarations -Wold-style-definition -O2 -I../include
> -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\"
> -D_GNU_SOURCE -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=\"/lib/xtables\"
> -DYY_NO_INPUT   -c -o m_ipt.o m_ipt.c
> cc1: warnings being treated as errors
> m_ipt.c:72: error: no previous prototype for 'xtables_register_target'
> m_ipt.c:361: error: no previous prototype for 'build_st'
> make[1]: *** [m_ipt.o] Error 1
> 
> This is fixed by adding the prototype in the header include/iptables.h
> 
> I am not sure if this is due to something wrong on my build system but I am
> using current glibc 2.17.
> 
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied, thanks
