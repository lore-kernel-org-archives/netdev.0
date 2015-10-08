From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v2 net-next 3/3] bpf: add unprivileged bpf tests
Date: Thu, 8 Oct 2015 10:55:51 -0700
Message-ID: <5616AE27.6060108@plumgrid.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
 <1444281803-24274-4-git-send-email-ast@plumgrid.com>
 <CAGXu5j+QA2uyvrNteoP1zQ5Cx6tAjVxR2zqmCi8148jS+_YW4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5j+QA2uyvrNteoP1zQ5Cx6tAjVxR2zqmCi8148jS+_YW4w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/8/15 10:46 AM, Kees Cook wrote:
>>   samples/bpf/libbpf.h        |    8 +
>> >  samples/bpf/test_verifier.c |  357 +++++++++++++++++++++++++++++++++++++++++--
> Instead of living in samples/ could these be moved and hooked up to
> tools/testing/selftests/ instead?

as a follow up patch. yes. of course.
along with test_maps.
Fengguang's todo already includes adding test_bpf.ko to 0-day buildbot.
