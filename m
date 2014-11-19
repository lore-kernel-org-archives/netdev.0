From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: net: sched: Deletion of an unnecessary check before the function
 call "kfree"
Date: Wed, 19 Nov 2014 20:09:25 +0100
Message-ID: <546CEAE5.9000305@redhat.com>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <546BAB93.4010406@users.sourceforge.net> <546CC9B3.5060405@gmail.com> <546CE650.6080205@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546CE650.6080205@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2014 07:49 PM, SF Markus Elfring wrote:
>> Marcus, what tree are you looking at?
>
> I dared to base this update suggestion on the source files
> for Linux 3.17.3. Are newer software developments relevant here?
>
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/log/net/sched/

Pointing to linux-next and saying you based your changes on 3.17.3
is confusing, please look correctly when you provide a link ...

Again, John's commit 1f947bf151e90ec0b removed the relevant part in
cls_bpf_modify_existing() that you're trying to modify:

$ git grep -n bpf_old net/sched/cls_bpf.c
$

Therefore, this patch is not needed.

Thanks !
