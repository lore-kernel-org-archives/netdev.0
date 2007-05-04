From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH][SOCK]: shrink struct sock
Date: Fri, 4 May 2007 22:17:31 +1200
Message-ID: <5640c7e00705040317t42ad8e3ak5e467eb46a81621d@mail.gmail.com>
References: <20070504041101.GA27519@ghostprotocols.net>
	 <20070503.212227.74561366.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.228]:15330 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993191AbXEDKRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 06:17:32 -0400
Received: by nz-out-0506.google.com with SMTP id o1so809693nzf
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 03:17:31 -0700 (PDT)
In-Reply-To: <20070503.212227.74561366.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/07, David Miller <davem@davemloft.net> wrote:
> sk_buff_head is due for being killed from the whole tree.  Nobody
> really needs the qlen, few things really need the lock, and those that
> do can define their own as needed :-)
>
I've got out of tree research code that uses the qlen quite
significantly. However it's not high speed networking so can compute
it myself if needed...
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
