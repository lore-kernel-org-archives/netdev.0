From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH next v0] bonding: Display LACP info only to
 CAP_SYS_ADMIN capable user
Date: Thu, 11 Jun 2015 14:09:35 -0700
Message-ID: <20150611140935.6533fb7c@urahara>
References: <1433981996-6010-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34126 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbbFKVJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 17:09:37 -0400
Received: by qgf75 with SMTP id 75so5768071qgf.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 14:09:37 -0700 (PDT)
In-Reply-To: <1433981996-6010-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Jun 2015 17:19:56 -0700
Mahesh Bandewar <maheshb@google.com> wrote:

> Actor and Partner details can be accessed via proc-fs and sys-fs
> entries. These interfaces are world readable at this moment. The
> earlier patch-series made the LACP communication secure to avoid
> nuisance attack from within the same L2 domain but it did not
> prevent "someone unprivileged" looking at that information on host
> and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

I would think you want CAP_NET_ADMIN for this?
