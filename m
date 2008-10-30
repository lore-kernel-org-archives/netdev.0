From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bpa10x: free sk_buff with kfree_skb
Date: Thu, 30 Oct 2008 05:09:34 +0100
Message-ID: <77F72F81-CC03-4032-A648-01B4F5D4CECC@holtmann.org>
References: <20081026.232626.97216182.davem@davemloft.net> <Pine.LNX.4.64.0810271821340.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:48178 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbYJ3EJj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 00:09:39 -0400
In-Reply-To: <Pine.LNX.4.64.0810271821340.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,

>> 2) Couple places trying to pass sk_buff to kfree() instead of
>>   kfree_skb().  Fixed by Sergio Luis
>
> I tried with coccinelle and found one more of these, though my
> other attempts with it haven't been all that successful...
>
>
> --
> [PATCH] bpa10x: free sk_buff with kfree_skb
>
> Inspired by Sergio Luis' similar patches, I finally found
> a case which is trivial enough that spatch won't choke
> on it.
>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

good catch.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Dave, feel free to take this directly and apply it to your trees.

Regards

Marcel

