From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Mon, 01 Sep 2014 12:37:05 -0400
Message-ID: <5404A0B1.1030009@mojatatu.com>
References: <20140826140630.GA1848@nanopsycho.lan>
 <53FCA0AE.9010304@mojatatu.com> <20140826152217.GA1843@nanopsycho.lan>
 <53FCA7C6.5070804@mojatatu.com> <20140826154459.GB1843@nanopsycho.lan>
 <20140826155426.GA5275@gospo.rtplab.test>
 <20140826161956.GA15316@casper.infradead.org>
 <CAADnVQLeNTQO9rekWRAb_2MWgiZqEiZ4p6GAsypdkhgg3xQffw@mail.gmail.com>
 <20140826205419.GH15316@casper.infradead.org> <54008C47.5040503@mojatatu.com>
 <20140901081343.GC12731@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Andy Gospodarek <gospo-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 Shrijeet Mukherjee <shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "Eric W. Biederman" <ebiederm@xm
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140901081343.GC12731-IxS8c3vjKQDk1uMJSBkQmQ@public.gmane.org>
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

On 09/01/14 04:13, Simon Horman wrote:
> On Fri, Aug 29, 2014 at 10:20:55AM -0400, Jamal Hadi Salim wrote:

>> I actually have no issues with whatever classifier someone decides
>> to use. To each their poison. But I do take issue mandating the
>> specified classifer it as THE CLASSIFIER as in this case,
>> is where i start taking issue. I have a few things that i offload
>> to hardware with speacilized classifiers such that i object strongly
>> to the approach this driver has taken.
>
> My reading of this thread is that allowing different classifiers
> is not under dispute.


I am not sure how you reached that conclusion by reading this thread;->
But i would be glad if that was the conclusion and i missed it.

cheers,
jamal
