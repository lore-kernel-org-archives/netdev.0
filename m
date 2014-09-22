From: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink
	API
Date: Mon, 22 Sep 2014 15:40:29 -0700
Message-ID: <CA+mtBx9ZVQ5r5Hzy9-uEnk+iu+HKkOP4+VANC06Xf8VvTxktwQ@mail.gmail.com>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com>
 <20140920081426.GE1821@nanopsycho.orion>
 <20140920105354.GA29419@casper.infradead.org>
 <CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
 <20140922081341.GA20905@casper.infradead.org>
 <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
 <20140922221727.GA4708@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
 Vladislav Yasevich <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev@
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140922221727.GA4708-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Mon, Sep 22, 2014 at 3:17 PM, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> On 09/22/14 at 08:10am, Tom Herbert wrote:
>> Thomas, can you (or someone else) quantify what the host case is. I
>> suppose there may be merit in using a switch on NIC for kernel bypass
>> scenarios, but I'm still having a hard time understanding how this
>> could be integrated into the host stack with benefits that outweigh
>
> Personally my primary interest is on lxc and vm based workloads w/
> end to end encryption, encap, distributed L3 and NAT, and policy
> enforcement including service graphs which imply both east-west
> and north-south traffic patterns on a host. The usual I guess ;-)
>
>> complexity. The history of stateful offloads in NICs is not great, and
>> encapsulation (stuffing a few bytes of header into a packet) is in
>> itself not nearly an expensive enough operation to warrant offloading
>
> No argument here. The direct benchmark comparisons I've measured showed
> only around 2% improvement.
>
> What makes stateful offload interesting to me is that the final
> desintation of a packet is known at RX and can be redirected to a
> queue or VF. This allows to build packet batches on shared pages
> while preserving the securiy model.
>
How is this different from what rx-filtering already does?

> Will the gains outweigh complexity? I hope so but I don't know for
> sure. If you have insights, let me know. What I know for sure is that
> I don't want to rely on a kernel bypass for the above.
>
>> to the NIC. Personally, I wish if NIC vendors are going to focus on
>> stateful offload I rather see it be for encryption which I believe
>> currently does warrant offload at 40G and higher speeds.
>
> Agreed. I would like to be see a focus on both.
