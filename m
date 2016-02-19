From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Fri, 19 Feb 2016 13:10:00 +0100
Message-ID: <56C70618.3010902@suse.cz>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org> <56C6EC62.8080107@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Takashi Iwai <tiwai@suse.com>
To: Tejun Heo <tj@kernel.org>, Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C6EC62.8080107@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/19/2016, 11:20 AM, Jiri Slaby wrote:
> On 02/18/2016, 06:44 PM, Tejun Heo wrote:
>> Hello,
>>
>> Can you please do the followings?
>>
>> 1. Remove WQ_MEM_RECLAIM from the affected workqueue and see whether
>>    the problem is reproducible.  WQ_MEM_RECLAIM on anything bluetooth
>>    doesn't make sense btw.  Why is it there?
>>
>> 2. If WQ_MEM_RECLAIM makes the issue go away, see whether the attached
>>    patch works too.
> 
> Hello,
> 
> 1. didn't help, the problem persists. So I haven't applied the patch from 2.

FWIW I dumped more info about the wq:
wq->name='hci0' pwq=ffff8800390d7600 wq->dfl_pwq=ffff8800390d5200
pwq->refcnt=2 pwq->nr_active=0 delayed_works: <nothing>

> thanks,
-- 
js
suse labs
