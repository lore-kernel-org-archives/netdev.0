From: "=?ISO-8859-1?Q?Mart=EDn_Ferrari?=" <martin.ferrari@gmail.com>
Subject: Re: IFF_PROMISC again
Date: Sat, 26 May 2007 03:28:27 -0300
Message-ID: <b9800b70705252328x6318c85es922e81662ce41762@mail.gmail.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
	 <465385F2.7080309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:47433 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbXEZG23 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 02:28:29 -0400
Received: by wa-out-1112.google.com with SMTP id j4so430642wah
        for <netdev@vger.kernel.org>; Fri, 25 May 2007 23:28:28 -0700 (PDT)
In-Reply-To: <465385F2.7080309@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On 5/22/07, Ben Greear <greearb@candelatech.com> wrote:

> > PACKET_(ADD|REMOVE)_MEMBERSHIP, I need to query the real device sta=
te.

> I have the same problem.  I think you can tell by looking at bit 0x10=
0
> in /sys/class/net/[ethX]/flags
>
> Not exactly fun to use, but it seems to work.

Wow, I searched for this a lot! It could be all I need, although it
doesn't seem very robust to look at the bitmap driectly, is it?

Maybe it would be cleaner to add an "promiscuity" file to that structur=
e?

--=20
Mart=EDn Ferrari
