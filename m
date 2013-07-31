From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: sendmsg() and vlan tags
Date: Tue, 30 Jul 2013 17:29:30 -0700
Message-ID: <CAOxq_8PW9ggzOeoXJGxP1+48O=0A=5HAdpP9JJoe_iz=a2vgtw@mail.gmail.com>
References: <CAOxq_8Ni_WszNj0RW++2jdmLwBxbQCJSSC-AS1Ux5TgMEpd2iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:45497 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757569Ab3GaA3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:29:52 -0400
Received: by mail-oa0-f51.google.com with SMTP id h2so167643oag.10
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 17:29:51 -0700 (PDT)
In-Reply-To: <CAOxq_8Ni_WszNj0RW++2jdmLwBxbQCJSSC-AS1Ux5TgMEpd2iA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello folks.

Can anyone please shed lights on this?

thanks,
ani


On Fri, Jul 26, 2013 at 2:30 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> Hi folks,
>
> We know that (since Linux 3.0) on raw sockets, the recvmsg() api
> returns the vlan tag information of the packet in the packet aux data.
> I looked at the kernel code and it seems on the TX side, in sendmsg(),
> we do not accept the vlan tag data from userland for a raw packet. So
> if the userland sends a raw packet using sendmsg() with vlan tag
> information in aux data, it will be discarded.
>
> Is my analysis correct?
>
> Cheers,
> Ani



-- 
Ani
