From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast path
Date: Sat, 4 Jul 2015 07:45:22 +0200
Message-ID: <CANn89i+9SPG9u3YPbjfJX_swTj-RUHhkUFadGL6JD7SpFHHwwg@mail.gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>
	<1435842455-30501-7-git-send-email-edumazet@google.com>
	<55966CEF.3000406@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>,
	Gregoire Baron <baronchon@n7mm.org>,
	Jiri Pirko <jiri@resnulli.us>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:33512 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbbGDFpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2015 01:45:24 -0400
Received: by wgck11 with SMTP id k11so101391420wgc.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 22:45:22 -0700 (PDT)
In-Reply-To: <55966CEF.3000406@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 3, 2015 at 1:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> Very nice Eric;-> thanks.
> So now basic accept/drop should be flying ;->
> Other really low hanging fruit is act_csum, vlan and skbedit.
> CCing the respective authors.

Note that act_mirred can be converted as well. I will do this because
this is my main usage.
