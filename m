From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/3] ss: Unify unix stats output from netlink
 and proc
Date: Sat, 3 Jan 2015 09:56:06 -0800
Message-ID: <20150103095606.03b741ed@urahara>
References: <1420245877-11763-1-git-send-email-vadim4j@gmail.com>
	<1420245877-11763-2-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46085 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbbACR4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 12:56:16 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so25741086pab.6
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 09:56:15 -0800 (PST)
In-Reply-To: <1420245877-11763-2-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good, but could you fix some minor style things.

On Sat,  3 Jan 2015 02:44:35 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

>  
> -static void unix_list_print(struct unixstat *list, struct filter *f)
> +static int unix_type_skip(struct unixstat *s, struct filter *f)
> +{

Please use bool for logical true/false value in new code.
