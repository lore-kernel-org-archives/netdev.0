From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 15:02:27 -0700
Message-ID: <1462917747.23934.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462916121.16365.14.camel@redhat.com>
	 <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Rik van Riel <riel@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 14:53 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 17:35 -0400, Rik van Riel wrote:
> 
> > You might need another one of these in invoke_softirq()
> > 
> 
> Excellent.
> 
> I gave it a quick try (without your suggestion), and host seems to
> survive a stress test.
> 
> Of course we do have to fix these problems :
> 
> [  147.781629] NOHZ: local_softirq_pending 48
> [  147.785546] NOHZ: local_softirq_pending 48
> [  147.788344] NOHZ: local_softirq_pending 48
> [  147.788992] NOHZ: local_softirq_pending 48
> [  147.790943] NOHZ: local_softirq_pending 48
> [  147.791232] NOHZ: local_softirq_pending 24a
> [  147.791258] NOHZ: local_softirq_pending 48
> [  147.791366] NOHZ: local_softirq_pending 48
> [  147.792118] NOHZ: local_softirq_pending 48
> [  147.793428] NOHZ: local_softirq_pending 48


Well, with your suggestion, these warnings disappear ;)
