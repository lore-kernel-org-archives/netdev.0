From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: Reset upper layer
 protocol info on internal devices.
Date: Mon, 03 Sep 2012 21:00:55 -0400 (EDT)
Message-ID: <20120903.210055.1839817610578900310.davem@davemloft.net>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
	<1342823210-3308-5-git-send-email-jesse@nicira.com>
	<CAEP_g=-giF74zveQgLsrAwS0kp2P3cj_O7mHaKKLVfKwQCNBag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=-giF74zveQgLsrAwS0kp2P3cj_O7mHaKKLVfKwQCNBag-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Mon, 3 Sep 2012 17:57:39 -0700

> On Fri, Jul 20, 2012 at 3:26 PM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>> It's possible that packets that are sent on internal devices (from
>> the OVS perspective) have already traversed the local IP stack.
>> After they go through the internal device, they will again travel
>> through the IP stack which may get confused by the presence of
>> existing information in the skb. The problem can be observed
>> when switching between namespaces. This clears out that information
>> to avoid problems but deliberately leaves other metadata alone.
>> This is to provide maximum flexibility in chaining together OVS
>> and other Linux components.
>>
>> Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> 
> It was recently discovered that the bug that this patch fixes is
> causing problems in the real world.  Can you please queue this for
> stable in 3.4/3.5?  It's currently in Linus's tree as
> 7fe99e2d434eafeac0c57b279a77e5de39212636.
> 

What vendor is shipping openvswitch enabled and requires the fix to
be in -stable before they'll ship it to customers?

That goes into what is 'real world'
