From: Debashis Dutt <debdut@gmail.com>
Subject: Re: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW trace
Date: Tue, 26 Apr 2011 19:16:29 -0700
Message-ID: <BANLkTinUsJ2foWKBVb_9nVFA2V_vKb11rA@mail.gmail.com>
References: <1303869117-780-1-git-send-email-rmody@brocade.com>
	<20110426185917.3d033636@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, netdev@vger.kernel.org,
	davem@davemloft.net, huangj@brocade.com, amathur@brocade.com,
	Debashis Dutt <ddutt@brocade.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33381 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756082Ab1D0CQb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 22:16:31 -0400
Received: by fxm17 with SMTP id 17so840433fxm.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 19:16:29 -0700 (PDT)
In-Reply-To: <20110426185917.3d033636@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 6:59 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 26 Apr 2011 18:51:57 -0700
> Rasesh Mody <rmody@brocade.com> wrote:
>
>> This is a RFC patch to Brocade BNA 10G Ethernet driver. It adds the =
generic
>> netlink communication interface to the BNA driver to collect firmwar=
e traces
>> using the in-kernel generic netlink infrastructure. The driver uses =
the
>> "dumpit" handler provided by the generic netlink layer to accomplish=
 this. The
>> driver can extend this interface later if required.
>>
>> As of today, there seems to be no standard mechanism to collect debu=
g
>> information such as firmware trace for a given hardware. Generic Net=
linki seems
>> to provide a suitable option to do the same, without any further
>> addition/modification to the existing kernel implementation.
>>
>> This is a RFC patch inviting suggestions/opinions for improvement/mo=
dification
>> and requesting consideration for possible inclusion in net-next tree=
=2E
>>
>> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>
> Seems like a lot of work for a debug interface. What about debugfs?
> Or is that out of favor now, I can never keep track...

Stephen,

Well, I think debugfs isn't always available, but there could always
be a driver
configuration option for that.

However, since the generic netlink is a more generic interface, we coul=
d use
this infrastructure in the driver for commands which are not part of
other standard tools.

Thanks
--Debashis
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
