From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Fix case when UDP is printed as
 ipproto-xxx
Date: Tue, 13 Jan 2015 17:33:21 -0800
Message-ID: <20150113173321.4b846db2@urahara>
References: <1420677774-10288-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:39640 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbbANBda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 20:33:30 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so7104549pad.10
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 17:33:29 -0800 (PST)
In-Reply-To: <1420677774-10288-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Jan 2015 02:42:54 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> When 'ss' prints UDP sockets info together with RAW sockets
> e.g.:
> 
>     $ ss -a
> 
> then UDP sockets are resolved as "ipproto-xxx".
> 
> It was caused that dg_proto was set after printing UDP
> socket info from netlink. So fixed issue by moving
> setting dg_proto before printing info from Netlink.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Accepted
