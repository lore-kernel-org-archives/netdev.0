From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 15:47:16 +0200
Message-ID: <34eeb39f-341b-19ba-0ef2-733b6b24dae7@stressinduktion.org>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <1462960104.4444.37.camel@redhat.com>
 <1462972112.23934.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <fbe7be9f-ba38-c003-5886-dae81d398b81@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fbe7be9f-ba38-c003-5886-dae81d398b81@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11.05.2016 15:39, Hannes Frederic Sowa wrote:
> I am fine with that. It is us to show clear benefits or use cases for
> that. If we fail with that, no problem at all that the patches get
> rejected, we don't want to add bloat to the kernel, for sure! At this
> point I still think a possibility to run napi in kthreads will allow
> specific workloads to see an improvement. Maybe the simple branch in
> napi_schedule is just worth so people can play around with it. As it
> shouldn't change behavior we can later on simply remove it.

Actually, I consider it a bug that when we force the kernel to use
threaded irqs that we only schedule the softirq for napi later on and
don't do the processing within the thread.

Bye,
Hannes
