From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] [UPDATED] ixgbe: add LRO support
Date: Fri, 13 Jun 2008 10:29:42 -0700
Message-ID: <9929d2390806131029k299804b9i2a1ce47395b98e4e@mail.gmail.com>
References: <20080613162643.27996.32104.stgit@localhost.localdomain>
	 <20080613093835.4b092360.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@daveloft.net
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:37577 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbYFMR3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 13:29:43 -0400
Received: by wa-out-1112.google.com with SMTP id j37so3362198waf.23
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 10:29:42 -0700 (PDT)
In-Reply-To: <20080613093835.4b092360.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2008 at 9:38 AM, Randy Dunlap <randy.dunlap@oracle.com> wrote:
>
> +       depends on PCI && INET
>
>> +     select INET_LRO
>
> If INET is not enabled, selecting INET_LRO still won't enable INET and
> build errors will result.  See the other drivers that select INET_LRO...
>
>

Thanks for the catch Randy.  I have updated the patch and will send it out.

-- 
Cheers,
Jeff
