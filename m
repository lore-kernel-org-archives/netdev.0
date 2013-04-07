From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH iproute2 2/2] ip: ipv6: add tokenized interface identifier
 support
Date: Sun, 07 Apr 2013 13:58:52 +0200
Message-ID: <51615F7C.2090100@redhat.com>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com> <1365086258-4512-3-git-send-email-dborkman@redhat.com> <20130405093914.55c9114c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933444Ab3DGL7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 07:59:03 -0400
In-Reply-To: <20130405093914.55c9114c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2013 06:39 PM, Stephen Hemminger wrote:
> On Thu,  4 Apr 2013 16:37:38 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> This is experimental support for tokenized IIDs, that enable
>> administrators to assign well-known host-part addresses to nodes
>> whilst still obtaining global network prefix from Router
>> Advertisements. It is currently in IETF RFC draft status [1].
>>
>> Example commands with iproute2:
>>
>> Setting a device token:
>>    # ip token set ::1a:2b:3c:4d/64 dev eth1
>>
>> Getting a device token:
>>    # ip token get dev eth1
>>    token ::1a:2b:3c:4d dev eth1
>>
>> Listing all tokens:
>>    # ip token list  (or: ip token)
>>    token :: dev eth0
>>    token ::1a:2b:3c:4d dev eth1
>>
>>   [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
>>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>
> Deferred.
> Please resubmit during 3.10 merge window.

Thanks, I'll do.
