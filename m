From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH] core, nfqueue, openvswitch: Orphan frags in skb_zerocopy
 and handle errors
Date: Wed, 19 Mar 2014 20:39:33 +0000
Message-ID: <532A0085.6070104@citrix.com>
References: <1395177455-2077-1-git-send-email-zoltan.kiss@citrix.com> <20140319.162459.897793286761249454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jesse@nicira.com>, <pshelar@nicira.com>, <tgraf@redhat.com>,
	<dev@openvswitch.org>, <pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <edumazet@google.com>,
	<dborkman@redhat.com>, <therbert@google.com>,
	<jasowang@redhat.com>, <fw@strlen.de>, <joe@perches.com>,
	<horms@verge.net.au>, <jiri@resnulli.us>, <mst@redhat.com>,
	<Paul.Durrant@citrix.com>, <JBeulich@suse.com>,
	<herbert@gondor.apana.org.au>, <mszeredi@suse.cz>,
	<netfilter-devel@vger.kernel.org>, <netfilter@vger.kernel.org>,
	<coreteam@netfilter.org>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kvm@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140319.162459.897793286761249454.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/03/14 20:24, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Tue, 18 Mar 2014 21:17:35 +0000
>
>> skb_zerocopy can copy elements of the frags array between skbs, but it doesn't
>> orphan them. Also, it doesn't handle errors, so this patch takes care of that
>> as well.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> ---
>>   net/openvswitch/datapath.c |    6 ++++++
>
> Something is seriously wrong with the diffstat generated for
> your submission, please fix this and resubmit.

Sorry, I've turned off diffstat in guilt a while ago, but this patch had 
an old version of it. I've resent it.

Zoli
