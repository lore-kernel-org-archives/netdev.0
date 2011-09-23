From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: Introducing open source MSTP daemon
Date: Fri, 23 Sep 2011 10:36:04 +0300
Message-ID: <201109231036.05039.vitas@nppfactor.kiev.ua>
References: <201109221727.33010.vitas@nppfactor.kiev.ua> <20110922163939.GB1012103@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:51923 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab1IWHhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 03:37:16 -0400
In-Reply-To: <20110922163939.GB1012103@jupiter.n2.diac24.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 September 2011 19:39:40 David Lamparter wrote:
> Very cool!
>
> The code looks quite good to me (i've only looked at 2 files though ;).
> Minor nitpicks:
>  - hmac_md5 & epoll could maybe come from an external library. you're
>    the 3810583th person to have code for that... libevent?
>    OpenSSL/gnutls?
>  - libnetlink.c is a copy from iproute2? since it is a fresh clean SVN,
>    it's not easy to know whether you made changes. Can you put a note
>    which version this is? Or maybe you can link it externally?
>  - the "assign" macro and "boolFalse" in mstp.c are weird. I understand
>    you want stricter type checking, but this makes the code somewhat
>    odd to read. Maybe external tools can be used to do this checking
>    (sparse, cppcheck, llvm's static analysis, ...)
>
Happy to hear you are interested )
I suppose these questions are not related to kernel development so I suggest 
to continue discussion on above topics at the project discussion board:
http://sourceforge.net/p/mstpd/discussion/

> I assume it works with current Linux kernel bridge code on a RSTP level?
> The code looks considerably more maintainable than rstpd :) - I will try
> running it later!
>
Sorry, at the moment function MSTP_OUT_set_state() does nothing except 
logging. But it is valueable thought: although MSTI states do not have 
meaning to the kernel bridge code, CIST states can be used to control bridge 
slave states, so mstpd can replace rstpd as more generic (and conforming to 
more recent standard).
Anyways, the code is basically untested. It compiles and runs in my setup, 
that's all for now. But I somehow have gut feeling that the code is mature 
enough to be put for the community consideration.

-- 
Vitalii Demianets
