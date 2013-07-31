From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sendmsg() and vlan tags
Date: Tue, 30 Jul 2013 17:56:46 -0700
Message-ID: <1375232206.10515.48.camel@edumazet-glaptop>
References: <CAOxq_8Ni_WszNj0RW++2jdmLwBxbQCJSSC-AS1Ux5TgMEpd2iA@mail.gmail.com>
	 <CAOxq_8PW9ggzOeoXJGxP1+48O=0A=5HAdpP9JJoe_iz=a2vgtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56136 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3GaA4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:56:49 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so206121pab.21
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 17:56:48 -0700 (PDT)
In-Reply-To: <CAOxq_8PW9ggzOeoXJGxP1+48O=0A=5HAdpP9JJoe_iz=a2vgtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 17:29 -0700, Ani Sinha wrote:
> hello folks.
> 
> Can anyone please shed lights on this?
> 
> thanks,
> ani
> 
> 
> On Fri, Jul 26, 2013 at 2:30 PM, Ani Sinha <ani@aristanetworks.com> wrote:
> > Hi folks,
> >
> > We know that (since Linux 3.0) on raw sockets, the recvmsg() api
> > returns the vlan tag information of the packet in the packet aux data.
> > I looked at the kernel code and it seems on the TX side, in sendmsg(),
> > we do not accept the vlan tag data from userland for a raw packet. So
> > if the userland sends a raw packet using sendmsg() with vlan tag
> > information in aux data, it will be discarded.


What is the vlan tag information value in aux data ?
