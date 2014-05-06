From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 19/24] net, diet: Make RPS configurable
Date: Tue, 06 May 2014 10:32:03 +0200
Message-ID: <87oazbux30.fsf@nemi.mork.no>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-20-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, Andi Kleen <ak@linux.intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-20-git-send-email-andi@firstfloor.org> (Andi
	Kleen's message of "Mon, 5 May 2014 15:26:08 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> writes:

> From: Andi Kleen <ak@linux.intel.com>
>
> Multiple receive queues are not needed on small systems,
> so allow disabling them.
>
> This is already disabled with !SMP, but it also makes
> sense to disable on very small SMP systems (like
> dual core SOC)

Such a pointless design still doesn't mean that you *have* to enable
SMP, does it?  How much would you save all over the kernel by simply
disabling SMP?

As for the system design: It seems to me that it would be more useful t=
o
replace one of the CPU cores with some RAM...


Bj=C3=B8rn
