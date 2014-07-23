From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: filter: split filter.c into two files
Date: Wed, 23 Jul 2014 10:54:04 +0200
Message-ID: <53CF782C.2040401@redhat.com>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com> <1406095319-3627-2-git-send-email-ast@plumgrid.com> <53CF522E.9090408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CF522E.9090408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/23/2014 08:11 AM, Varka Bhadram wrote:
> On 07/23/2014 11:31 AM, Alexei Starovoitov wrote:
>> BPF is used in several kernel components. This split creates logical boundary
>> between generic eBPF core and the rest
>>
>> kernel/bpf/core.c: eBPF interpreter
>>
>> net/core/filter.c: classic->eBPF converter, classic verifiers, socket filters
>>
>> This patch only moves functions.
>
> If we are moving the code also its good to do cleanup.
>
> Run checkpatch.pl on this...

Not sure what you understand as a cleanup, but there's nothing
wrong with it and most things reported are either intentional or
false positives as you might have seen already. The only thing
one could do later on perhaps is to rename related functions to
have consistently a 'bpf' prefix instead of 'sk' since they
won't be under net/ anymore.
