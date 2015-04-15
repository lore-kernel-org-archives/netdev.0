From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Wed, 15 Apr 2015 11:19:08 +0200
Message-ID: <552E2D0C.6090809@iogearbox.net>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org> <20150410132205.GF23070@casper.infradead.org> <20150410200901.GB5968@salvia> <20150412.211421.1771298417488412635.davem@davemloft.net> <20150413201913.GD20275@acer.localdomain> <552D07C4.1020509@mojatatu.com> <552D2E52.8020303@intel.com> <20150414153613.GA2781@Alexeis-MBP.westell.com> <552E14B4.7060907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, pablo@netfilter.org,
	tgraf@suug.ch, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <552E14B4.7060907@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/15/2015 09:35 AM, John Fastabend wrote:
> On 04/14/2015 08:36 AM, Alexei Starovoitov wrote:
>> On Tue, Apr 14, 2015 at 08:12:18AM -0700, John Fastabend wrote:
>>>
>>> I was hoping to push the skb lists onto something like rte_ring
>>> used by the DPDK folks or possibly some of the lockless ring work Jesper
>>> created. This is needed for many qdisc's to drop the qlock but not the
>>> ingress qdisc. Been busy working on switch bits lately but might be
>>> able to pick this up next merge window.
>>
>> I've spent quite a bit of time reanalyzying your work ;) It seems
>> only trivial stuff left to drop ingress spinlock. Can you send me
>> your TC test scripts ? I'm only starting building mine and they're
>> not covering everything. Roughly I'm creating namespaces and running
>> traffic between them while varying csum/gso/gro offload settings.
>
> I'll dig up my scripts and post them to github this weekend. They
> are a bit organized and all over the place at the moment.
>
> Maybe we can build a master repository. I know there a lot of different
> scripts running around, for example I already collected a few from
> Jamal and I think Cong must have some as well.

Sounds awesome, I think that will be really useful for better test
coverage.
