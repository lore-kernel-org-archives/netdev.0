From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH 1/3] Kernel interfaces for multiqueue aware socket
Date: Fri, 17 Dec 2010 14:15:16 +0800
Message-ID: <AANLkTimmt9Y9aLNXU7=hOKvgEenkw2bsb43QBenM0YSE@mail.gmail.com>
References: <cover.1292405004.git.fenghua.yu@intel.com>
	<46a08278c2ba21737528eb4b77391a7e8bc88000.1292405004.git.fenghua.yu@intel.com>
	<1292446118.2603.11.camel@edumazet-laptop>
	<AANLkTikc+QTPH2He=fKgWiRGk=6sn9Phaa259YdkQNix@mail.gmail.com>
	<1292475627.2603.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fenghua Yu <fenghua.yu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Xinan Tang <xinan.tang@intel.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292475627.2603.39.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 16, 2010 at 1:00 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 09:52 +0800, Junchang Wang a =C3=
=A9crit :
>> Commit 564824b0c52c34692d had been used in the experiments, but the =
problem
>> remained unsolved.
>>
>> SLUB was used, and both servers were equipped with 8G physical memor=
y.
>> Is there any
>> additional information I can provide?
>>
>
> Yes, sure, you could provide a description of the bench you used, and
> data you gathered to make the conclusion that NUMA was a problem.
>
Under the current circumstances (1Mpps), we can hardly see side effects
from memory allocator. With higher speed (say, 5Mpps with this patch se=
t),
the problem emerged.

I'll continue this work after the patch set is done.


Thanks.
--=20
--Junchang
