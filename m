From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next] ipvlan: Fix failure path in dev registration during
 link creation
Date: Wed, 27 Apr 2016 13:39:23 -0700
Message-ID: <CAF2d9jhFg1dTOFe6HsmsP0kOmkpMf6OK3ciUUxqS2=zn8DOzcg@mail.gmail.com>
References: <1461782259-10806-1-git-send-email-mahesh@bandewar.net> <20160427.145742.1732984000881376610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mahesh@bandewar.net, Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>, ebiederm@xmission.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33828 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbcD0Ujo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:39:44 -0400
Received: by mail-yw0-f175.google.com with SMTP id j74so88755219ywg.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 13:39:44 -0700 (PDT)
In-Reply-To: <20160427.145742.1732984000881376610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 11:57 AM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <mahesh@bandewar.net>
> Date: Wed, 27 Apr 2016 11:37:39 -0700
>
>> While fixing this issue I noticed another issue of missing unregister
>> in case of failure, so adding it to the fix which is similar to the
>> macvlan fix by Francesco in SHA1:308379607548524b8d86dbf20134681024935e0b
>
> This is not the correct way to refer to commits.
>
> You should specify, exactly, 12 digits of the SHA1 value, followed by
> a space, followed by the header line text of that commit contained in
> parenthesis and double quotes, like how Fixes: tags specify commits.
Ok, will fix that soon.
