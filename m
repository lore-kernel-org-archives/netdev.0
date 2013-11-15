From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2 v4] Open vSwitch zerocopy upcall
Date: Fri, 15 Nov 2013 17:34:12 +0800
Message-ID: <CAEP_g=9gjBYB_K1rD+WWQdJXxUZ-vDLBBeUTio8KEz6TJrMKpw@mail.gmail.com>
References: <cover.1383906944.git.tgraf@suug.ch>
	<20131114.021357.2293924326693299062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20131114.021357.2293924326693299062.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Thu, Nov 14, 2013 at 3:13 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Date: Fri,  8 Nov 2013 11:47:16 +0100
>
>> Respin of the zerocopy patches for the openvswitch upcall.
>>
>> V4: - Daniel Borkmann pointed out that the style in skbuff.h has changed
>>       in net-next, adapted to no longer using extern in headers.
>> V3: - Removed unneeded alignment of nlmsg_len after padding
>> V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
>>       buffer. This also takes care of the from->head_frag issue.
>>     - Attribute alignment for frag_list case
>>     - API documentation
>>     - performance data for CHECKSUM_PARTIAL tx case
>>
>> Thomas Graf (2):
>>   net: Export skb_zerocopy() to zerocopy from one skb to another
>>   openvswitch: Use skb_zerocopy() for upcall
>
> No objections from me for these changes, but it's too late for the
> current merge window.
>
> Jesse can feel free to queue this up in his tree and you can add my:
>
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>
> to these patches.
>
> Thanks!

Thanks - there's some discussion related to these patches in the
thread "linux: Signal datapath that unaligned Netlink message can be
received" so I'm waiting until that concludes.
