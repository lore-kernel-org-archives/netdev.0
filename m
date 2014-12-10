From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 REGRESSIONS v3] ss: Fix layout/output issues
 introduced by regression
Date: Tue, 9 Dec 2014 20:32:30 -0800
Message-ID: <20141209203230.55e6a45e@urahara>
References: <1417799951-25143-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:40335 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbaLJEcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:32:39 -0500
Received: by mail-pd0-f182.google.com with SMTP id p10so1949005pdj.41
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:32:39 -0800 (PST)
In-Reply-To: <1417799951-25143-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Dec 2014 19:19:11 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> This patch fixes the following issues which was introduced by me in commits:
> 
>     #1 (2dc854854b7f1b) ss: Fixed broken output for Netlink 'Peer Address:Port' column
>     ISSUE: Broken layout when all sockets are printed out
> 
>     #2 (eef43b5052afb7) ss: Identify more netlink protocol names
>     ISSUE: Protocol id is not printed if 'numbers only' output was specified (-n)
> 
> Also aligned the width of the local/peer ports to be more wider.
> 
> I tested with a lot of option combinations (I may miss some test cases),
> but layout seems to me better than the previous released version of iproute2/ss.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied.
Thanks for following through and dealing with this.
