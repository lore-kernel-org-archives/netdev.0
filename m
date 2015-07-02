From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Thu, 2 Jul 2015 14:24:33 -0700
Message-ID: <CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
 <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
 <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
 <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg> <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33894 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbbGBVYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:24:53 -0400
Received: by qkeo142 with SMTP id o142so61351194qke.1
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:24:52 -0700 (PDT)
In-Reply-To: <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 2, 2015 at 2:18 PM, Alex Gartrell <alexgartrell@gmail.com> wrote:
> If early demux was enabled, we'd use the route from the socket

Actually now that I think about it, this is probably broken, because
we don't reply to the packet but instead silently drop it.

-- 
Alex Gartrell <agartrell@fb.com
