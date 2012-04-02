From: Matt Turner <mattst88@gmail.com>
Subject: Re: [PATCH V1 1/1] NET: add a bpf jit for Alpha
Date: Mon, 2 Apr 2012 16:43:17 -0400
Message-ID: <CAEdQ38FnZXLiPM4CtOhT5X9qj9jLt84x=NhcSSbGO1agSNc24w@mail.gmail.com>
References: <4F75CA89.4010709@googlemail.com> <4F7A033D.4040901@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org,
	rth@redhat.com
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-alpha-owner@vger.kernel.org>
In-Reply-To: <4F7A033D.4040901@googlemail.com>
Sender: linux-alpha-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 2, 2012 at 3:51 PM, Jan Seiffert
<kaffeemonster@googlemail.com> wrote:
> The weekend was cold and windy, so i wrote a bpf jit for the Alpha architecture.
>
> Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>
>
> ---
>
> Patch is against net-next and needs Patch 1 of my "Fix negative offsets" Series
> (to get bpf_internal_load_pointer_neg_helper)
>
> The Problem is: i don't have any Alpha machine nor do i really have any clue about
> the arch.
> So this is only compile tested.
> I could really need some Alpha asm guru to give some advice and review this.
> Are the calls done right, are the asm load helper ok, all the conditional and
> sign handling is a little brittle in my mind, etc.

Very cool. I'll try to find some time soon to test this.

Thanks a lot!
Matt
