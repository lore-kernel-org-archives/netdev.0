From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: Use eth_mac_addr()
 instead of duplicating it
Date: Mon, 3 Dec 2012 14:55:17 -0800
Message-ID: <CAEP_g=_sAOsQAXQXELDUAc3vFPgXAYbQUG6THfcsuNvXg7+M8A@mail.gmail.com>
References: <20121203221732.GA14494@casper.infradead.org>
	<CAEP_g=8+V=LN--ZkAgRHysUWwNJH1O=YDevbLH846nGZQkUpUA@mail.gmail.com>
	<20121203224721.GC14494@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20121203224721.GC14494-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On Mon, Dec 3, 2012 at 2:47 PM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> On 12/03/12 at 02:36pm, Jesse Gross wrote:
>> On Mon, Dec 3, 2012 at 2:17 PM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
>> >
>> > bonus: if we ever are to use IFF_LIVE_ADDR_CHANGE for
>> > anything further than to check availability in eth_mac_addr(),
>> > Open vSwitch will be ready for that.
>> >
>> > Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
>>
>> There's no need to send this patch twice (especially to a different
>> set of people).  I'm currently reviewing a large patchset that was
>> submitted before yours.
>
> It's a trivial patch, you seemed busy and we might as well make use
> of the open net-next window. I see nothing wrong with that.

If you send patches like this to two different trees then it will
result in merge conflicts later.  Please just wait a few days; as you
say, it's a trivial patch.
