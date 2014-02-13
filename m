From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: ovs inconsistent lock state
Date: Thu, 13 Feb 2014 15:23:14 -0500 (EST)
Message-ID: <20140213.152314.1937497665232682958.davem@davemloft.net>
References: <20140213181257.GD2829@minipsycho.orion>
	<20140213.142654.2111989507538583557.davem@davemloft.net>
	<20140213200753.GE2829@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140213200753.GE2829-RDzucLLXGGI88b5SBfVpbw@public.gmane.org>
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

From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Date: Thu, 13 Feb 2014 21:07:53 +0100

> Thu, Feb 13, 2014 at 08:26:54PM CET, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org wrote:
>>From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>Date: Thu, 13 Feb 2014 19:12:57 +0100
>>
>>>>> [ 3014.524118]  [<ffffffff815eb585>] ? __dev_queue_xmit+0x5/0x6a0
>>  ...
>>> I fail to see where bh is disabled. ovs_dp_process_received_packet() is
>>> called with rcu_read_lock...
>>
>>It happens in __dev_queue_xmit(), which does rcu_read_lock_bh().
> 
> On tx yes. But how about rx? I don't see it there (rx_handler path).
> Maybe I'm missing something.

For this code path they are one in the same.
