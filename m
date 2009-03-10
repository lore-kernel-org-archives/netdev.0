From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC 2/4] net: netfilter conntrack - add per-net functionality
 	for DCCP protocol
Date: Tue, 10 Mar 2009 14:56:37 +0300
Message-ID: <49B65575.1050500@openvz.org>
References: <20090309181628.109019157@gmail.com>	 <20090309182731.762563452@gmail.com> <49B63EA6.2060802@free.fr>	 <49B6420B.4080309@free.fr>	 <aa79d98a0903100359x5cba797fu9611823b91c64b42@mail.gmail.com>	 <49B65076.6090003@openvz.org> <aa79d98a0903100451r6179ca61l3573cd8ae6e171b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>,
	Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <aa79d98a0903100451r6179ca61l3573cd8ae6e171b7@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> I believe Daniel means, that we need the register_xxx_get_subsys call
>> for subsystems, rather than devices, that will behave according to the
>> generic net pointers.
>>
>> Daniel, am I right with this suggestion?
>>
> ...
> Ah, yes, just checked register_pernet_gen_subsys -- it's what I need. Thanks!
> 

Good. This would require some factorization work as well. Cyrill, your turn ;)
