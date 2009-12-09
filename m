From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: Re: nfs broken in net-next? -- now in mainline
Date: Wed, 9 Dec 2009 12:34:36 -0800
Message-ID: <86802c440912091234t74fd2311t33c85379c06dd55c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Suresh Jayaraman <sjayaraman@suse.de>, Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757753AbZLIUei@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2009 at 2:03 AM, Yinghai Lu <yhlu.kernel@gmail.com> wrote:
> On Thu, Oct 29, 2009 at 12:23 AM, Suresh Jayaraman <sjayaraman@suse.de> wrote:
>> On 10/29/2009 01:43 AM, Yinghai Lu wrote:
>>> pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
>>> mount.nfs: rpc.statd is not running but is required for remote locking.
>>> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>>
>> rpc.statd on client should have be started by mount.nfs when a nfs
>> filesystem is mounted. Is this not happening for some reason or do you
>> see any errors in syslog?
>>
>>>
>>> using opensuse11.1
>>>
>>
>> Are you using 11.1 betas? I know of a problem where non-root user mounts
>> fail to start rpc.statd in betas that got fixed later:
>>
>> http://marc.info/?l=linux-nfs&m=122748525624094&w=2
>>
>> Is the problem seen only recently (after updating to net-next)?
>>
>
> only happen with net-next.
>
> linus tree and tip tree are ok.
>

Finally it reached linus tree and tip.

YH
