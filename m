From: Tomas Hozza <thozza@redhat.com>
Subject: Re: SOCK_STREAM TCP: send() returns success even when other side
 responded with RST packet
Date: Tue, 19 Feb 2013 10:46:40 -0500 (EST)
Message-ID: <671340739.1911519.1361288800967.JavaMail.root@redhat.com>
References: <1361287646.19353.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:41796 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758410Ab3BSPqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 10:46:42 -0500
In-Reply-To: <1361287646.19353.131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> On Tue, 2013-02-19 at 10:09 -0500, Tomas Hozza wrote:
> 
> > I'm using TCP because it should guarantee that my data were
> > delivered or
> > let me know there was some problem. If this is not a bug, then it
> > is at least
> > confusing for TCP.
> 
> Note that a write() on a regular file descriptor has same semantic :
> By default, there is no guarantee data is written on stable storage.
> 
> > 
> > > To make sure data is delivered, you need additional logic.
> > 
> > To be honest I didn't find any way how to get notified there was a
> > RST packet
> > sent as a reply to my previously sent data.
> 
> Well, I suggest you read the man pages and some books, as this is
> well
> explained, you are not the first guy wanting to exchange data using
> TCP.
> 
> man 7 socket
> 
>        SO_LINGER
>               Sets or gets the SO_LINGER option.  The argument is a
>               linger structure.
> 
>                   struct linger {
>                       int l_onoff;    /* linger active */
>                       int l_linger;   /* how many seconds to linger
>                       for */
>                   };
> 
>               When enabled, a close(2) or shutdown(2) will not return
>               until all queued messages
>               for  the  socket  have  been  successfully  sent  or
>                the linger timeout has been
>               reached.  Otherwise, the call returns immediately and
>               the closing is done in  the
>               background.   When  the socket is closed as part of
>               exit(2), it always lingers in
>               the background.
> 
> man 2 shutdown

I don't think you understood what I was asking for and this is not the right
place to discuss how to do things. I have read Unix Network Programming from
Richard Stevens but did not find answer for this either. Thanks anyway.
