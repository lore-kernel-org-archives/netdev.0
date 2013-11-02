From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 08/11] openvswitch: Per cpu flow
	stats.
Date: Sat, 2 Nov 2013 14:51:34 -0700
Message-ID: <CAEP_g=9r2zAW7Ph9_qSDir3VJyOetjiFdMO2Vf2Wk9M0hs=JGg@mail.gmail.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
	<1383092544-50599-9-git-send-email-jesse@nicira.com>
	<20131029.221125.343749464995759893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20131029.221125.343749464995759893.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Tue, Oct 29, 2013 at 7:11 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date: Tue, 29 Oct 2013 17:22:21 -0700
>
>> From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>>
>> With mega flow implementation ovs flow can be shared between
>> multiple CPUs which makes stats updates highly contended
>> operation. Following patch allocates separate stats for each
>> CPU to make stats update scalable.
>>
>> Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>
> Please properly use __percpu memory for this.
>
> Using arrays for this is very strongly discouraged, please instead
> use the kernel facility designed exactly for this.

Pravin had some concerns about the effects of high churn rate on the
percpu allocator, which is why he did it this way initially. I'm going
to drop this patch for now and send out the rest of the series while
he investigates further.
