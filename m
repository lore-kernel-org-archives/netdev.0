From: Yuchung Cheng <ycheng@google.com>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 12:50:05 -0700
Message-ID: <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
References: <1376508095.4596.12.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:50223 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758601Ab3HNTuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 15:50:25 -0400
Received: by mail-ob0-f174.google.com with SMTP id wd6so12556226obb.33
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 12:50:25 -0700 (PDT)
In-Reply-To: <1376508095.4596.12.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 12:21 PM, Damian Lukowski
<damian@tvk.rwth-aachen.de> wrote:
> Hi,
>
> the TCP specification states that an endpoint has to accept
> packets from the other side even after it has half-closed the
> connection locally. This does not seem to be the case
> under Linux?
>
> For example, when I wget -O /dev/null https://www.verisign.com/
> --max-redir 0, the local TCP stack sends an FIN,ACK close to the end.
> However, the webserver has more data to send (Encrypted Alert).
> Instead of ACKing the packet, the local side sends a RST.
> This seems wrong to me.

Which wget are you using? it's not doing half-close (i.e.,
shutdown(SHUT_WR)) on my wget version 1.13.4


>
> Regards
>  Damian
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
