From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH net-next] tc: bpf: add checksum helpers
Date: Thu, 2 Apr 2015 17:15:30 +0200
Message-ID: <20150402151530.GD2613@nanopsycho.orion>
References: <1427933533-14394-1-git-send-email-ast@plumgrid.com>
 <551D599F.30408@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <551D599F.30408-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thu, Apr 02, 2015 at 05:00:47PM CEST, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org wrote:
>On 04/02/2015 02:12 AM, Alexei Starovoitov wrote:
>>Commit 608cd71a9c7c ("tc: bpf: generalize pedit action") has added the
>>possibility to mangle packet data to BPF programs in the tc pipeline.
>>This patch adds two helpers bpf_l3_csum_replace() and bpf_l4_csum_replace()
>>for fixing up the protocol checksums after the packet mangling.
>>
>>It also adds 'flags' argument to bpf_skb_store_bytes() helper to avoid
>>unnecessary checksum recomputations when BPF programs adjusting l3/l4
>>checksums and documents all three helpers in uapi header.
>>
>>Moreover, a sample program is added to show how BPF programs can make use
>>of the mangle and csum helpers.
>>
>>Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>
>I think in future we need to find a better place for these helpers,
>as they are for cls_bpf and act_bpf.

Yeah, makes sense to now have it in net/core/filter.c. How about to
create net/bpf dir for these?

>
>Acked-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
