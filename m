From: Andy Zhou <azhou@nicira.com>
Subject: Re: [patch net-next 4/4] net: refactor IPv4 and IPv6 defragmentation APIs
Date: Tue, 10 Mar 2015 11:54:06 -0700
Message-ID: <CACzMAJJzket7TddMdB1Oy20g64brRK1qYO=ORhQVOB=TMiGyhA@mail.gmail.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
	<1425888098-21875-5-git-send-email-azhou@nicira.com>
	<20150309091537.GA13498@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:50310 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751161AbbCJSyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:54:07 -0400
Received: by mail-oi0-f53.google.com with SMTP id z81so3450944oif.2
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 11:54:06 -0700 (PDT)
In-Reply-To: <20150309091537.GA13498@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2015 at 2:15 AM, Simon Horman <simon.horman@netronome.com> wrote:
> Hi Andy,
>
> On Mon, Mar 09, 2015 at 01:01:38AM -0700, Andy Zhou wrote:
>> Both ip_defrag() and nf_ct_frag6_gather() derive the name space
>> information from the netdev device attached to the skb. However,
>> packets processed by  openvswitch may not have a netdev device.
>>
>> This patch adds new ip_defrag_net() and  nf_ct_frag6_gather_net()
>> API that accepts net as an argument.
>>
>> Signed-off-by: Andy Zhou <azhou@nicira.com>
>
> [snip]
>
>> @@ -645,6 +652,7 @@ void nf_ct_frag6_consume_orig(struct sk_buff *skb)
>>               s = s2;
>>       }
>>  }
>> +EXPORT_SYMBOL(nf_ct_frag6_consume_orig);
>>
>>  static int nf_ct_net_init(struct net *net)
>>  {
>
> This hunk seems unrelated to the changelog and the rest of the patch.
Will do.
