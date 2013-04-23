From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Mon, 22 Apr 2013 23:51:09 -0700
Message-ID: <20130422235109.296696a4@nehalam.linuxnetplumber.net>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
	<20130422.160834.1941810644323096368.davem@davemloft.net>
	<1366687841.21136.6.camel@cr0>
	<1366698455.21136.11.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34242 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749Ab3DWGvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:51:13 -0400
Received: by mail-pd0-f172.google.com with SMTP id 4so234144pdd.17
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 23:51:12 -0700 (PDT)
In-Reply-To: <1366698455.21136.11.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Apr 2013 14:27:35 +0800
Cong Wang <amwang@redhat.com> wrote:

> After several tries, I think it is not easy to do at all, it relies on
> some icmp functions at least, which are still compiled as a module. So,
> I can't think out any easier solution than simply adding Kconfig
> dependency.

Why is IPv6 support depending on ICMP functions? Everything doesn't
have to be hyper optimized, at least not initially.
