From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Tue, 22 Mar 2011 21:35:37 +0100
Message-ID: <4D890819.5020202@gmail.com>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com> <20110322202634.GA11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41164 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab1CVUfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 16:35:42 -0400
Received: by wya21 with SMTP id 21so7088432wya.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 13:35:40 -0700 (PDT)
In-Reply-To: <20110322202634.GA11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/03/2011 21:26, Andy Gospodarek a =E9crit :
> On Tue, Mar 22, 2011 at 01:38:12PM +0100, Jiri Pirko wrote:
>> This prevents possible race between bond_enslave and bond_handle_fra=
me
>> as reported by Nicolas by moving rx_handler register/unregister.
>> slave->bond is added to hold pointer to master bonding sructure. Tha=
t
>> way dev->master is no longer used in bond_handler_frame.
>> Also, this removes "BUG: scheduling while atomic" message
>>
>> Reported-by: Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
> Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
>
> This seems reasonable.  I presume Nicolas was able to test it and ver=
ify
> it resolved his issue?

Unfortunately, not yet. I plan to give it a try tonight... or tomorrow =
on the worst case.

	Nicolas.
