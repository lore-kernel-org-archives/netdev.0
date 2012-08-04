From: =?UTF-8?Q?S=C5=82awek_Janecki?= <janecki@gmail.com>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Sat, 4 Aug 2012 20:07:46 +0200
Message-ID: <CACS4u_y23MvgnK-sbcNv7pxgaDYJLvzXZa68QKE__NckwM_XSQ@mail.gmail.com>
References: <20120727183840.GE17572@p12n.org> <26496.1343419205@death.nxdomain>
 <20120801144104.GN17572@p12n.org> <CAEuXFExg2X9r0zE8wUs9Npd7jPUN2WHbyJcnH6eT_23f2DoPjw@mail.gmail.com>
 <20120804162219.GT17572@p12n.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	jgoerzen@efolder.net
To: Peter Samuelson <psamuelson@efolder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:52893 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948Ab2HDSIH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 14:08:07 -0400
Received: by vcbfk26 with SMTP id fk26so1652557vcb.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 11:08:06 -0700 (PDT)
In-Reply-To: <20120804162219.GT17572@p12n.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have no such info in dmsg.
I think I will file a issue to Node.js Dev Team.
Thanks for reply.

On Sat, Aug 4, 2012 at 6:22 PM, Peter Samuelson <psamuelson@efolder.net=
> wrote:
>
> [Jesse Brandeburg]
>> try
>> # ethtool -K ethx tso off gso off lro off
>
> Wow - that worked!  Thanks so much!  Now I'll see if I can narrow it
> down a bit from there.
>
> Then it's on to the mystery of why I have to explicitly set eth2+eth3
> 'promisc' - the bond0 device is supposed to propagate that setting bu=
t
> apparently it doesn't.  (Lower priority, though, since there's an eas=
y
> workaround.)
>
> Peter
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20

pozdrawiam
S=C5=82awomir Janecki
