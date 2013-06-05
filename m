From: Tommi Rantala <tt.rantala@gmail.com>
Subject: Re: vhost && kernel BUG at /build/linux/mm/slub.c:3352!
Date: Wed, 5 Jun 2013 15:06:33 +0300
Message-ID: <CA+ydwtq6FNSXhjGuqtQBUKVQJNOD_iKWpnUqj4rbfQJTkw+bog@mail.gmail.com>
References: <CA+ydwtrtpA3jXojG3tKt_-ueJOWDSOL1trM9h6F5qLvdoonUOw@mail.gmail.com>
	<20130605115408.GA2643@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	trinity@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605115408.GA2643@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/6/5 Michael S. Tsirkin <mst@redhat.com>:
> On Tue, Jun 04, 2013 at 09:50:59PM +0300, Tommi Rantala wrote:
>> Hello,
>>
>> Hit this right after killing trinity with Ctrl-C. Was fuzzing
>> v3.10-rc4-0-gd683b96 in a qemu virtual machine as the root user.
>>
>> Tommi
>
> Thanks a lot for the report. If found some bugs when looking
> at this: I think they were introduced by
> 2839400f8fe28ce216eeeba3fb97bdf90977f7ad
> though I don't exactly see how ctrl-c can trigger this.
> I'll work on patches - is this reproducible at all?

Thanks, glad to hear that the report was useful.

Yes, I did reproduce this quite quickly yesterday with trinity, but
did not dig any deeper into what was going on.

Tommi
