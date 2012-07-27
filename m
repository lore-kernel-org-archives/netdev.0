From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2 0/7] TCP Fast Open client
Date: Fri, 27 Jul 2012 13:42:52 +0200
Message-ID: <CAHO5Pa0D-hS=zdEEyUWMN6bmpKvQgiy25nTu1=BUYVxec+zpsQ@mail.gmail.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:39551 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866Ab2G0LnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 07:43:13 -0400
Received: by gglu4 with SMTP id u4so3033929ggl.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 04:43:12 -0700 (PDT)
In-Reply-To: <1342645307-17772-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuchung,

On Wed, Jul 18, 2012 at 11:01 PM, Yuchung Cheng <ycheng@google.com> wrote:
> ChangeLog since v1:
>   - Reduce tons of code by storing Fast Open stats in the TCP metrics :)
>   - Clarify the purpose of using an experimental option in patch 1/7
>
> This patch series implement the client functionality of TCP Fast Open.
> TCP Fast Open (TFO) allows data to be carried in the SYN and SYN-ACK
> packets and consumed by the receiving end during the initial connection
> handshake, thus providing a saving of up to one full round trip time (RTT)
> compared to standard TCP requiring a three-way handshake (3WHS) to
> complete before data can be exchanged.
>
> The protocol change is detailed in the IETF internet draft at
> http://www.ietf.org/id/draft-ietf-tcpm-fastopen-00.txt . The research

This URL appears to be invalid. I assume the following is the correct
current version:
http://tools.ietf.org/html/draft-ietf-tcpm-fastopen-01
?

Is there some sample client and server userspace test code available?

Thanks,

Michael

-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/
