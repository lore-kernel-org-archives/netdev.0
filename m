From: =?UTF-8?Q?S=C5=82awek_Janecki?= <janecki@gmail.com>
Subject: Re: TCP stalls with 802.3ad + bridge + kvm guest
Date: Sat, 4 Aug 2012 21:21:30 +0200
Message-ID: <CACS4u_xhcLCUT6EFmhazePamwHDYipgMSPdJxVOG4U9frLfikQ@mail.gmail.com>
References: <20120727183840.GE17572@p12n.org> <26496.1343419205@death.nxdomain>
 <20120801144104.GN17572@p12n.org> <CAEuXFExg2X9r0zE8wUs9Npd7jPUN2WHbyJcnH6eT_23f2DoPjw@mail.gmail.com>
 <20120804162219.GT17572@p12n.org> <CACS4u_y23MvgnK-sbcNv7pxgaDYJLvzXZa68QKE__NckwM_XSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	jgoerzen@efolder.net
To: Peter Samuelson <psamuelson@efolder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:64352 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754050Ab2HDTVw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 15:21:52 -0400
Received: by vbbff1 with SMTP id ff1so1621942vbb.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 12:21:51 -0700 (PDT)
In-Reply-To: <CACS4u_y23MvgnK-sbcNv7pxgaDYJLvzXZa68QKE__NckwM_XSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wrong mail sorry

On Sat, Aug 4, 2012 at 8:07 PM, S=C5=82awek Janecki <janecki@gmail.com>=
 wrote:
> I have no such info in dmsg.
> I think I will file a issue to Node.js Dev Team.
> Thanks for reply.
>
> On Sat, Aug 4, 2012 at 6:22 PM, Peter Samuelson <psamuelson@efolder.n=
et> wrote:
>>
>> [Jesse Brandeburg]
>>> try
>>> # ethtool -K ethx tso off gso off lro off
>>
>> Wow - that worked!  Thanks so much!  Now I'll see if I can narrow it
>> down a bit from there.
>>
>> Then it's on to the mystery of why I have to explicitly set eth2+eth=
3
>> 'promisc' - the bond0 device is supposed to propagate that setting b=
ut
>> apparently it doesn't.  (Lower priority, though, since there's an ea=
sy
>> workaround.)
>>
>> Peter
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
>
> pozdrawiam
> S=C5=82awomir Janecki



--=20

pozdrawiam
S=C5=82awomir Janecki
