From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] libnetlink: don't confuse variables in
 rtnl_talk()
Date: Thu, 10 Dec 2015 08:49:29 -0800
Message-ID: <20151210084929.33fa7bcf@xeon-e3>
References: <1449159228-4233-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34212 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbbLJQtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 11:49:22 -0500
Received: by pacwq6 with SMTP id wq6so50027436pac.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 08:49:22 -0800 (PST)
In-Reply-To: <1449159228-4233-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Dec 2015 17:13:48 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> There is two variables named 'len' in rtnl_talk. In fact, commit
> c079e121a73a didn't work. For example, it was possible to trigger
> a seg fault with this command:
> $ ip link set gre2 type ip6gre hoplimit 32
> 
> Let's rename the argument len to maxlen.
> 
> Fixes: c079e121a73a ("libnetlink: add size argument to rtnl_talk")
> Reported-by: Thomas Faivre <thomas.faivre@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks, Not sure why compiler isn't catching this.
