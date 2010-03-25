From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: why does the tcp_time_wait() call tcp_done(sk)?
Date: Thu, 25 Mar 2010 18:01:04 +0800
Message-ID: <4BAB3460.4000906@cn.fujitsu.com>
References: <ffe582101003242024o23ddbdc9w7aaffde382c3da8b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?5p2o56GV?= <shanqn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58324 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752506Ab0CYKBw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 06:01:52 -0400
In-Reply-To: <ffe582101003242024o23ddbdc9w7aaffde382c3da8b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E6=9D=A8=E7=A1=95 wrote, at 03/25/2010 11:24 AM:
> that means the connection has been closed?
> Does kernel think like that???
> we can use "STATE_TRACE" to see FIN_WAIT_2--->CLOSE rather than
> FIN_WAIT_2-->TIME_WAIT-->CLOSE.

There are three functions to call tcp_time_wait() with FIN_WAIT_2.
Can you provide the fully function call stack?


tcp_close  tcp_rcv_state_process  =20
   \        |=20
    \       |
     \      |
      -|/  \|/
    tcp_time_wait
         /|\
          |
          |
 tcp_keepalive_timer


--=20
Best Regards
-----
Shan Wei
