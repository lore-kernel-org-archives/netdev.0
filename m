From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip lib: Added shorter timestamp option
Date: Mon, 22 Dec 2014 10:12:12 -0800
Message-ID: <20141222101212.04877275@urahara>
References: <1418285526-28859-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:56721 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbaLVSMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:12:23 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so6327991pad.23
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 10:12:22 -0800 (PST)
In-Reply-To: <1418285526-28859-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2014 10:12:06 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added another timestamp format to look like more logging info:
> 
> [Dec 01 01:46:20.675589] 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
>     link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I would suggest supporting RFC3339 which is a standard for timestamps instead.

[2014-22-12T01:46:20.1012] ...
