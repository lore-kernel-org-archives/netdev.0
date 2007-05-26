From: "=?ISO-8859-1?Q?Mart=EDn_Ferrari?=" <martin.ferrari@gmail.com>
Subject: Re: IFF_PROMISC again
Date: Sat, 26 May 2007 03:42:20 -0300
Message-ID: <b9800b70705252342n7ca29111k15f82f86c287e36@mail.gmail.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
	 <465385F2.7080309@candelatech.com>
	 <20070522.171225.70219741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:27922 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbXEZGmV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 02:42:21 -0400
Received: by py-out-1112.google.com with SMTP id a73so1741489pye
        for <netdev@vger.kernel.org>; Fri, 25 May 2007 23:42:21 -0700 (PDT)
In-Reply-To: <20070522.171225.70219741.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 5/22/07, David Miller <davem@davemloft.net> wrote:

> > Anyone know the reasoning for masking out the PROMISC flag
> > in dev_get_flags() ?
>
> Because promiscuous status is a counter, not a binary
> on-off state.
>
> You can't expect to just clear it and expect all the
> other promiscuous users to just "go away" and be ok
> with the device leaving promiscuous mode.

Yes, this is fully understood.

> Since you can't sanely "set" it, we don't provide it
> either.

I think it's cleaner how is done now, but the needed information is
hidden, not having a proper way of querying the counter or the real
(binary) promiscuous state is a problem for userspace. Do you think
the patch I suggested is not a good idea?

Do you think there is a acceptable way of exporting that info to
userspace? (as I just said to Ben, the /sys/.../flags file doesn't
seem a very clean way of checking it).

--=20
Mart=EDn Ferrari
