From: James Bourne <jbourne@hardrock.org>
Subject: Re: via_rhine/qdisc Dead loop on netdevice eth1, fix it urgently!
Date: Sun, 23 Apr 2006 11:04:05 -0600 (MDT)
Message-ID: <Pine.LNX.4.64.0604231102420.27317@bama.hardrock.org>
References: <Pine.LNX.4.58.0604140935220.4085@ldap2.hardrock.org>
 <20060423113107.GA16193@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bama.hardrock.org ([68.146.16.251]:65484 "EHLO
	mail.hardrock.org") by vger.kernel.org with ESMTP id S1751427AbWDWREH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 13:04:07 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060423113107.GA16193@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 23 Apr 2006, Herbert Xu wrote:

> On Fri, Apr 14, 2006 at 03:51:15PM +0000, James Bourne wrote:
>>
>> Apr 14 08:32:54 bama kernel:  [<c02becbb>] netpoll_send_skb+0xa8/0x100     [<f8c4c174>] write_msg+0x140/0x181 [netconsole]
>
> This is the culprit.  Disable that and the problem will go away.

That's done now, but...  This has been happening for a while now, and I had
enabled netdump/netconsole to try and troubleshoot the problem if there was
a crash involved (which unfortunately there never has been).

Thanks though, and if/when it happens I'll let you know.

Regards
James

>
> Cheers,
>

-- 
James Bourne                  | Email:            jbourne@hardrock.org
UNIX Systems Administration   | WWW:           http://www.hardrock.org
Custom UNIX Programming       | Linux:  The choice of a GNU generation
----------------------------------------------------------------------
  "All you need's an occasional kick in the philosophy." Frank Herbert
