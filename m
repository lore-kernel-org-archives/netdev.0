From: Luca Ellero <luca.ellero@brickedbrain.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix checkpatch errors
Date: Wed, 04 Jun 2014 08:49:46 +0200
Message-ID: <538EC18A.1010308@brickedbrain.com>
References: <1401806702-3251-1-git-send-email-luca.ellero@brickedbrain.com> <20140603204843.GA13364@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpdg228.aruba.it ([62.149.158.228]:47268 "EHLO
	smtpdg12.aruba.it" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932723AbaFDGtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 02:49:51 -0400
In-Reply-To: <20140603204843.GA13364@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 03/06/2014 22:48, Patrick McHardy ha scritto:
> On Tue, Jun 03, 2014 at 04:45:02PM +0200, Luca Ellero wrote:
>> Add parenthesis around complex macros
>>
>> Signed-off-by: Luca Ellero <luca.ellero@brickedbrain.com>
>> ---
>>   net/netfilter/nf_conntrack_pptp.c       |    6 +++---
>>   net/netfilter/nf_conntrack_proto_sctp.c |    8 ++++----
>>   net/netfilter/nf_conntrack_proto_tcp.c  |    8 ++++----
>>   3 files changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
>> index 825c3e3..a505263 100644
>> --- a/net/netfilter/nf_conntrack_pptp.c
>> +++ b/net/netfilter/nf_conntrack_pptp.c
>> @@ -92,9 +92,9 @@ const char *const pptp_msg_name[] = {
>>   EXPORT_SYMBOL(pptp_msg_name);
>>   #endif
>>
>> -#define SECS *HZ
>> -#define MINS * 60 SECS
>> -#define HOURS * 60 MINS
>> +#define SECS  (*HZ)
>> +#define MINS  (*60 SECS)
>> +#define HOURS (*60 MINS)
>
> Don't send patches that you obviously didn't even compile test.
>

beg your pardon, my bad... send it by mistake
Sorry for the noise
Regards
Luca
