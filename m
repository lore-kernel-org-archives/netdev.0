From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 3 Sep 2015 08:13:06 +0000
Message-ID: <D20DBEF2.437A0%Shaun.Crampton@metaswitch.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
 <20150826074959.48aea34c@as>
 <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
 <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
 <55E7907D.9000606@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Marineau <michael.marineau@coreos.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E7907D.9000606@iogearbox.net>
Content-Language: en-US
Content-ID: <E2659F5D3B283B4790B8A8A82D785AEA@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>Looking at this one, I am still puzzeled where 0xffffffffa008772b and
>0xffffffffa008772b comes from ... some driver, bridge ...?

Is there anything I can do on a running system to help figure this out?
Some sort of kernel equivalent to pmap to find out what module or device
owns that chunk of memory?
