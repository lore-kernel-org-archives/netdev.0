From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [v4.6-rc7-183-g1410b74e4061]
Date: Mon, 16 May 2016 19:42:35 +0200
Message-ID: <CA+icZUUJed6KqxhPKyrr_ACCfnp09T+R5S0J8-Bf6+1SJZvtoQ@mail.gmail.com>
References: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
	<20160516105045.GA19189@gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160516105045.GA19189@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/16/16, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Sedat Dilek <sedat.dilek@gmail.com> wrote:
>
>> Hi,
>>
>> as Linux v4.6 is very near, I decided to write this bug report (only
>> drunk one coffee).
>>
>> First, I am not absolutely sure if this is a real issue as...
>> #1: This is only a (lockdep) warning.
>> #2: I have not a "vanilla" Linux v4.6-rc7+ here (see P.S. and attached
>> patch)
>
> Having such a kernel base is certainly not helpful to the quality of your
> report,
> please try to reproduce under the vanilla kernel.
>
>> For a more helpful feedback I should test a...
>> #1: vanilla v4.6-rc7-183-g1410b74e4061
>
> I'd suggest v4.6 plus this debug patch from Peter:
>
>   https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1142352.html
>
> ... to see whether something fishy is going on.
>
> Thanks,
>

Unfortunately, I could not reproduce this again with none of my 183-kernels.
When I first hit a "chain_key collision" issue, it was hard to redproduce, so.
Any idea, how I can "force" this?

- Sedat -
