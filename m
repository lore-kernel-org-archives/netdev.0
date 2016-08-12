From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tipc: refactor bearer identification
Date: Fri, 12 Aug 2016 12:54:20 -0700
Message-ID: <20160812125420.755070d9@xeon-e3>
References: <1470731670-12723-1-git-send-email-richard.alpe@ericsson.com>
	<1470731670-12723-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34625 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbcHLTyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:54:10 -0400
Received: by mail-pa0-f42.google.com with SMTP id fi15so11294407pac.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 12:54:10 -0700 (PDT)
In-Reply-To: <1470731670-12723-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Aug 2016 10:34:30 +0200
Richard Alpe <richard.alpe@ericsson.com> wrote:

> Introduce a generic function (nl_add_bearer_name()) that identifies a
> bearer and adds it to an existing netlink message. This reduces code
> complexity and makes the code a little bit easier to maintain.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>

This causes warning on GCC 6 (Debian Testing).

tipc
    CC       bearer.o
bearer.c: In function ‘cmd_bearer_disable’:
bearer.c:325:14: warning: unused variable ‘opt’ [-Wunused-variable]
  struct opt *opt;
              ^
    LINK     tipc


Please fix and resubmit.
