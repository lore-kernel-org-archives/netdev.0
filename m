From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports for
	bridging device
Date: Wed, 25 Mar 2009 15:05:20 +0800
Message-ID: <2a27d3730903250005w2e773b01x1e9ec0606fc0e3d4@mail.gmail.com>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
	 <20090324.234051.60226102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:35360 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbZCYHFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 03:05:22 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2702798rvb.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 00:05:20 -0700 (PDT)
In-Reply-To: <20090324.234051.60226102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 2:40 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Li Yang <leoli@freescale.com>
> Date: Fri, 20 Mar 2009 17:04:29 +0800
>
>> The bridging device used a constant hard_header_len. =C2=A0This will=
 cause
>> headroom shortage for ports with additional hardware header. =C2=A0T=
he patch
>> makes bridging device to use the maximum value of all ports.
>>
>> Signed-off-by: Li Yang <leoli@freescale.com>
>
> Your driver must be able to cope with any amount of
> available headroom, no matter what hacks we put into
> the bridging layer.
>
> Please fix your driver, I'm not applying this patch.

Ok.  But it's not good to reallocate every packet generated locally.
Why not take this patch too?

- Leo
