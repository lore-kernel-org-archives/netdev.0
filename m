From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH] Revert "af-packet: Use existing netdev reference for
 bound sockets."
Date: Sun, 17 Nov 2013 21:06:14 -0800
Message-ID: <CAO7SqHAJwYmVDQq5WNuB8uMwGS3fEH_6aDx1YtNz+HQJO9sfLQ@mail.gmail.com>
References: <1384734522-36613-1-git-send-email-noureddine@aristanetworks.com>
	<20131117.212812.2002429039119385634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:61120 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3KRFGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 00:06:15 -0500
Received: by mail-vc0-f179.google.com with SMTP id hz11so3285481vcb.38
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 21:06:14 -0800 (PST)
In-Reply-To: <20131117.212812.2002429039119385634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will fix it. Thanks.

On Sun, Nov 17, 2013 at 6:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Salam Noureddine <noureddine@aristanetworks.com>
> Date: Sun, 17 Nov 2013 16:28:42 -0800
>
>> This reverts commit 827d978037d7d0bf0860481948c6d26ead10042f.
>>
>> The patch introduced a race condition between packet_snd and packet_notifier
>> when a net_device is being unregistered. In the case of a bound socket,
>> packet_notifier can drop the last reference to the net_device and packet_snd
>> might be sending a packet over a freed net_device.
>
> You need to provide a proper "Signed-off-by: ", you need to refer to
> commits not just buy SHA1 ID but also by the commit header text in
> parenthesis and double quotes.
