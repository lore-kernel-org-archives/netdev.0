From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink
	API
Date: Sat, 20 Sep 2014 08:35:52 -0400
Message-ID: <541D74A8.6080501@mojatatu.com>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com> <20140920081702.GF1821@nanopsycho.orion>
 <541D54BA.6070709@mojatatu.com> <20140920110121.GB29419@casper.infradead.org>
 <541D65CE.7080108@mojatatu.com> <20140920115140.GA3777@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140920115140.GA3777-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 09/20/14 07:51, Thomas Graf wrote:

> I fail to see the connection. You can use switch vendor SDK no matter
> how we define the kernel APIs. They already exist and have been
> designed in a way to be completely indepenedent from the kernel.
>
> Are you referring to vendor specific decisions in user space in
> general? I believe that the whole point of swdev is to provide *that*
> level of abstraction so decisions can be made in a vendor neutral way.
>

I am not against the swdev idea. I think we have disagreements
for the general classification/action interface how that should look
like - but that is resolvable with correct interfaces.
The vendor neutral way *already exists* via current netlink
abstractions that existing tools use. When we need to add new
interfaces then we should.

> I don't think anybody is saying that. P4 is likely a reality soon. But
> we definitely want hardware offload in a BPF world even if the hardware
> can't do BPF yet.
>


I dont think we have contradictions. We are speaking past each other.
You implied that in the future OVS s/w path might be based on BPF.
I implied BPF itself could be offloaded and stands on its own merit
and should work if we have the correct interface. As an example,
I dont care about P4 or OVS - but i have no problem if they use
the common interfaces provided by Linux. i.e
If i want to build  a little cpu running the BPF instruction set
and use that as my offload then that interface should work and if
it doesnt i should provide extensions.

> Not sure I understand. OVS would be a user of eBPF just like tracing,
> xt_BPF, socket filter, ...
>

Ok, we are on the same page then.

> As I said, this can be argued about. It would require to push a lot of
> context into the kernel though. The FDB offload is relatively trivial
> in comparison to the complexity OVS user space can handle. I can't think
> of any reasons why to complicate the kernel further with OVS specific
> knowledge as long as we can guarantee the vendor abstraction.
>

I disagree. OVS maybe complex in that sense (I am sorry i am making
an assumption based on what you are saying) but i dont think there is
any other kernel subsystem that has this challenge.
Note: i am pointing to fdb only because it carries the concept of "put
this in hardware and/or software". I agree the fdb maybe reasonably
simpler.

cheers,
jamal
