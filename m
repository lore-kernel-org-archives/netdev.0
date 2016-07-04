From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Tue, 5 Jul 2016 00:02:09 +0200
Message-ID: <577ADCE1.6010506@oracle.com>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com>
 <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg>
 <577ABF71.6020002@oracle.com>
 <alpine.LFD.2.11.1607050014000.2228@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31774 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcGDWC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 18:02:28 -0400
In-Reply-To: <alpine.LFD.2.11.1607050014000.2228@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2016 11:24 PM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Mon, 4 Jul 2016, Vegard Nossum wrote:
>
>> Alright.
>>
>> Thanks for the review! I can submit a new patch to only check the one
>> place above that actually crashed. Otherwise, if you think it's better
>> to go with your fc_flags suggestion, feel free to send a patch for that.
>> As you can tell, I am not very familiar with this code :-) If you do
>> send a patch, I can test it easily.
>
> 	Of course, here is untested version. May be I'll do some
> testing this weekend and will submit with proper commit
> message...
>
> [PATCH RFC] ipv4: reject RTNH_F_LINKDOWN for incompatible routes
>
> The RTNH_F_LINKDOWN flag is used only for link routes.
> Reject it for error routes and local routes.
>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Tested your patch, it fixes the problem for me. I haven't tested if it
breaks anything else :-)


Vegard
