From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] lib: introduce arch optimized
	hash library
Date: Thu, 12 Dec 2013 19:04:14 +0100
Message-ID: <52A9FA9E.6090604@redhat.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com>
	<1386860946-1621-2-git-send-email-ffusco@redhat.com>
	<52A9F84F.8060500@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <52A9F84F.8060500-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/12/2013 06:54 PM, Nicolas Dichtel wrote:
...
> Is it possible to trace that this comes from the DPDK?
> At least in the commit log, like it was done in the v1.

Hm, that got lost; but we can put that back into the commit log.
In any case, we properly included the header comment, of course.

>> +static inline u32 crc32_u32(u32 crc, u32 val)
>> +{
>> +    asm ("crc32l %1,%0\n" : "+r" (crc) : "rm" (val));
> I'm not an expert, but is it not possible to use intrisics functions, like it is
> done in the original code?

Intrinsics are not used/available in the kernel, so we used asm
as everywhere else.
