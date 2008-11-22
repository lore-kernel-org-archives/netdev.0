From: "Andrew Brampton" <brampton@gmail.com>
Subject: Re: Receive Side Support (RSS) - Adding support into the kernel
Date: Sat, 22 Nov 2008 17:04:29 +0000
Message-ID: <d41814900811220904q3b25a46dtb0e008b7222b8449@mail.gmail.com>
References: <d41814900811210948p2fb2059epbd381a8105ab8959@mail.gmail.com>
	 <20081121.152612.60802006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:42696 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758604AbYKVREa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 12:04:30 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1405284rvb.1
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2008 09:04:29 -0800 (PST)
In-Reply-To: <20081121.152612.60802006.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/11/21 David Miller <davem@davemloft.net>:
> From: "Andrew Brampton" <brampton@gmail.com>
> Date: Fri, 21 Nov 2008 17:48:22 +0000
>
>> Hi,
>> Recently I've been interested in receive side support (RSS)[1], the
>
> It's receive side "scaling", not "support".
>
>> There are three RSS settings which can be configured
>> 1) Which fields of the packet get hashed.
>> 2) The key used by the hashing algorithm
>> 3) The indirection table, which is used to map a 7bit hash value to a
>> particular core.
>
> We already have an ethtool interface for configuring aspects of this,
> with more knobs on the way.
>

Well thanks David, and Ben for your input. I am aware that the S in
RSS was for scaling, I obviously had a error between my brain and my
keyboard.

Anyway, I look forward to the changes appearing in ethtool, and if I
see a opportunity to help out, then I will offer my assistance.
Perhaps I'll try and add the ethtool rx_hash support to the ixgbe
drivers (since I have a couple of these cards). I guess I'll speak to
the Intel guys about that.

thanks for your time
Andrew
