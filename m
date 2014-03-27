From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next RFC v2 2/6] skbuff: add "missed_flow"
	flag
Date: Thu, 27 Mar 2014 11:34:27 +0100
Message-ID: <20140327103427.GG2845@minipsycho.orion>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-3-git-send-email-jiri@resnulli.us>
 <5333FE0E.2090008@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5333FE0E.2090008-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
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

Thu, Mar 27, 2014 at 11:31:42AM CET, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org wrote:
>Le 26/03/2014 17:31, Jiri Pirko a =E9crit :
>>This flag sets incoming switch device in order to let know that the flow
>>which the skb is part of is missed. Listener may react to it
>>appropriately,
>>
>>Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>---
>>  include/linux/filter.h |  1 +
>>  include/linux/skbuff.h | 13 +++++++++++++
>>  net/core/filter.c      |  3 +++
>>  3 files changed, 17 insertions(+)
>>
>>diff --git a/include/linux/filter.h b/include/linux/filter.h
>>index e568c8e..38c7c04 100644
>>--- a/include/linux/filter.h
>>+++ b/include/linux/filter.h
>>@@ -154,6 +154,7 @@ enum {
>>  	BPF_S_ANC_VLAN_TAG,
>>  	BPF_S_ANC_VLAN_TAG_PRESENT,
>>  	BPF_S_ANC_PAY_OFFSET,
>>+	BPF_S_ANC_MISSED_FLOW,
>>  };
>>
>>  #endif /* __LINUX_FILTER_H__ */
>>diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>index 03db95a..0100c2f 100644
>>--- a/include/linux/skbuff.h
>>+++ b/include/linux/skbuff.h
>>@@ -567,6 +567,7 @@ struct sk_buff {
>>  	 * headers if needed
>>  	 */
>>  	__u8			encapsulation:1;
>>+	__u8			missed_flow:1;
>>  	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
>Please fix also the comment.

will do. Thanks.
