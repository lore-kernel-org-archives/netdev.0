From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][IPROUTE2] Fixup u32 pretty printing
Date: Sun, 20 Apr 2008 11:00:08 -0400
Message-ID: <1208703608.12249.62.camel@localhost>
References: <1208702635.12249.48.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:8473 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbYDTPAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 11:00:12 -0400
Received: by an-out-0708.google.com with SMTP id d31so384843and.103
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 08:00:11 -0700 (PDT)
In-Reply-To: <1208702635.12249.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-20-04 at 10:43 -0400, jamal wrote:

> --------
> hadi@lilsol:~$ tc -c filter ls dev lo parent ffff:
> 
> filter protocol ip pref 9 u32 fh 801::802 order 2050 key ht 801 bkt 0
> flowid 1:16
>   match IP src 10.0.0.2/32
>   match IP protocol 6
>   match sport 53
> 
> hadi@lilsol:~$ tc -c filter ls dev lo parent ffff:

Above,  cutnpaste mistake, should be:
 "tc filter ls dev lo parent ffff:"

i.e the original way of dumping filters...

> 
> filter protocol ip pref 9 u32 fh 801::802 order 2050 key ht 801 bkt 0
> flowid 1:16
>   match 0a000002/ffffffff at 12
>   match 00060000/00ff0000 at 8
>   match 00000035/0000ffff at 20
> --------

cheers,
jamal

