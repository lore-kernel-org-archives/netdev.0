From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 1/1] net: sched: Deletion of an unnecessary check before
 the function call "kfree"
Date: Wed, 19 Nov 2014 18:00:14 +0100
Message-ID: <546CCC9E.7090905@redhat.com>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <546BAB93.4010406@users.sourceforge.net> <546CC9B3.5060405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org, Coccinelle <cocci@systeme.lip6.fr>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546CC9B3.5060405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2014 05:47 PM, John Fastabend wrote:
> On 11/18/2014 12:26 PM, SF Markus Elfring wrote:
>> From: Markus Elfring <elfring@users.sourceforge.net>
...
>>       if (fp_old)
>>           bpf_prog_destroy(fp_old);
>> -    if (bpf_old)
>> -        kfree(bpf_old);
>> +    kfree(bpf_old);
>>
>>       return 0;
>>
>
> Maybe I need some coffee but I can't figure out what this
> patch is against...
>
> # grep bpf_old ./net/sched/cls_bpf.c
> #

Coffee is always good. :)

Yeah, you actually removed this in commit 1f947bf151e90ec ("net:
sched: rcu'ify cls_bpf"), so looks like Markus's tree is not
up to date ...
