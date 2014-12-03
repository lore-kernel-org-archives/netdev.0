From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in
 handle_netlink_request
Date: Wed, 3 Dec 2014 09:21:29 -0800
Message-ID: <20141203092129.49f16769@urahara>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36351 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaLCRVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:21:39 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so15841246pdj.37
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:21:38 -0800 (PST)
In-Reply-To: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Dec 2014 16:53:04 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Replaced handling netlink messages by rtnl_dump_filter
> from lib/libnetlink.c, also:
> 
>     - removed unused dump_fp arg;
>     - added MAGIC_SEQ #define for 123456 seq id
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

This doesn't work correctly.

Simple test
  $ misc/ss >/dev/null
RTNETLINK answers: No such file or directory
RTNETLINK answers: No such file or directory
RTNETLINK answers: No such file or directory
