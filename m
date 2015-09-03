From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 03 Sep 2015 05:10:43 -0700
Message-ID: <1441282243.8932.219.camel@edumazet-glaptop2.roam.corp.google.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
	 <20150826074959.48aea34c@as>
	 <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
	 <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
	 <55E7907D.9000606@iogearbox.net>
	 <D20DBEF2.437A0%Shaun.Crampton@metaswitch.com>
	 <55E80CFA.7050408@iogearbox.net>
	 <D20DDAB4.437AF%Shaun.Crampton@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Michael Marineau <michael.marineau@coreos.com>,
	Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D20DDAB4.437AF%Shaun.Crampton@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-09-03 at 10:09 +0000, Shaun Crampton wrote:
> >...
> >> Is there anything I can do on a running system to help figure this out?
> >> Some sort of kernel equivalent to pmap to find out what module or device
> >> owns that chunk of memory?
> >
> >Hmm, perhaps /proc/kallsyms could point to something. 0xffffffffa0087d81
> >and 0xffffffffa008772b could be from the same module, if any.
> 
> Any good: https://transfer.sh/szGRE/kallsyms ?
> 

seems to be cryptd module.

Have you tried to run an pristine upstream kernel ?
