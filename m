From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 3.0 release
Date: Fri, 22 Jul 2011 13:35:16 -0700
Message-ID: <CA+55aFwX55HhzyPsb5vx-=xkHpWJBH0481ZFWcXnNzH1M6zhdg@mail.gmail.com>
References: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
 <4E29CB5B.4040408@unsolicited.net> <CA+55aFy1FnVGH4C_0T8fXwZPUdz5-SCczMwy1K8kydLwTx89RQ@mail.gmail.com>
 <4E29D326.7070403@candelatech.com> <20110722133220.0baf2199@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Greear <greearb@candelatech.com>,
	David <david@unsolicited.net>, Tejun Heo <tj@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110722133220.0baf2199@nehalam.ftrdhcpuser.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 22, 2011 at 1:32 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>
> The workqueue code should have a fallback and not try and
> do anything if being called from IRQ.

Fair enough. Especially since one of the *points* of workqueues is
indeed to schedule stuff from irqs and that cannot be done
immediately.

Tejun?

                  Linus
