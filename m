From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: asconf's process should verify address
 parameter is in the beginning
Date: Tue, 25 Aug 2015 20:28:51 +0800
Message-ID: <CADvbK_d43Qb86Mjx7BuP9tC_DSw-bO=o2k7nyhw=-Y7Tp6ft9g@mail.gmail.com>
References: <87d339ea910a3665c9376b6ba69b003af967c6d1.1440410878.git.lucien.xin@gmail.com>
	<55DB557C.6090506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	davem <davem@davemloft.net>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35811 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372AbbHYM2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 08:28:52 -0400
Received: by obbwr7 with SMTP id wr7so140366969obb.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 05:28:52 -0700 (PDT)
In-Reply-To: <55DB557C.6090506@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Sorry, you can't do that directly without a lot more checks.  The parameer
> may be only only partial, or may not be there at all.  You'd end up looking
> at wrong mememory.
>
> A better way would be to set the addr_param_seen only when looking at
> the first parameter (addip_hdr.params).
>
I will repost it
