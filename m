From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pulling net tree into net-next
Date: Wed, 05 Jun 2013 21:26:46 -0700
Message-ID: <1370492806.24311.329.camel@edumazet-glaptop>
References: <1370453224.24311.287.camel@edumazet-glaptop>
	 <20130605.161511.2267769342649279605.davem@davemloft.net>
	 <1370492302.24311.327.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:47413 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190Ab3FFE0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 00:26:48 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so2772241pdi.21
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 21:26:48 -0700 (PDT)
In-Reply-To: <1370492302.24311.327.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-05 at 21:18 -0700, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 16:15 -0700, David Miller wrote:
> 
> > Working on it now, I need to handle some details in the merge commit so
> > give me some time.
> 
> Thanks David, it seems nicely done ;)
> 
> 

Oh well, my machines do not work anymore...

Seems to be related to this commit, because I do have 32bit user
programs (and a 64bit kernel)

commit 1be374a0518a288147c6a7398792583200a67261
Author: Andy Lutomirski <luto@amacapital.net>
Date:   Wed May 22 14:07:44 2013 -0700

    net: Block MSG_CMSG_COMPAT in send(m)msg and recv(m)msg
    
