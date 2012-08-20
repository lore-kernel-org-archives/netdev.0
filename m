From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Fwd: TCP fragmentation broken in 3.6-rc ?
Date: Mon, 20 Aug 2012 16:56:21 +0200
Message-ID: <CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
References: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58575 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab2HTO4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 10:56:22 -0400
Received: by vbbff1 with SMTP id ff1so5386543vbb.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 07:56:21 -0700 (PDT)
In-Reply-To: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems somehow something was broken in 3.6-rc.
I'm not sure exactly what though. The symptoms are:

 - TCP connection get "stuck" with data in send queue when doing
"large" transfers ( like typing 'ps ax' on a ssh connection )
 - Only happens on path where the PMTU is lower than the MTU of the interface
 - Is not present right after boot, it only appears 10-20min after
boot or so. (and that's inside the _same_ TCP connection, it works
fine at first and then in the same ssh session, it'll get stuck)
 - Definitely seems related to fragments somehow since I see a router
sending ICMP message saying fragmentation is needed.
 - Exact same setup works fine with kernel 3.5.1

Cheers,

    Sylvain
