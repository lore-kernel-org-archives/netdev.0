From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next 01/13] openvswitch: split flow
 structures into ovs specific and generic ones
Date: Wed, 03 Sep 2014 21:54:01 -0400
Message-ID: <5407C639.1040408@mojatatu.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>	<1409736300-12303-2-git-send-email-jiri@resnulli.us>	<CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>	<54078694.5040104@mojatatu.com>
 <CALnjE+qUqSK7kHSi5BZuA0hzFjMcZ8TCTd9JRG1PPmMfDmAQOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "ryazanov.s.a" <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jasowang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "john.r.fastabend" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "neil.jerram" <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 andy <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 nbd <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, "f.fainelli" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Rony Efraim <ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "jeffrey.t.kirsher" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 buytenh <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, aviadr <aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 nhorman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+qUqSK7kHSi5BZuA0hzFjMcZ8TCTd9JRG1PPmMfDmAQOA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 09/03/14 17:59, Pravin Shelar wrote:

> Both of us are saying same thing.
> What I meant was for OVS use-case, where OVS wants to use offload for
> switching flows, vswitchd userspace process can program HW offload
> using kernel HW offload APIs directly from userspace, rather than
> going through OVS kernel module. If user wants to use some other tool,
> then the tool can use same kernel HW offload APIs.

Ok, sorry, you are right - we are saying the same thing.

cheers,
jamal
