From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 2/2] net: ixgbe: implement af_packet direct queue
 mappings
Date: Tue, 13 Jan 2015 19:18:12 +0100
Message-ID: <54B56164.7060100@redhat.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <20150113043542.29985.15658.stgit@nitbit.x32> <54B52B25.1070809@redhat.com> <54B53DED.4040502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956AbbAMSS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 13:18:27 -0500
In-Reply-To: <54B53DED.4040502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 04:46 PM, John Fastabend wrote:
> On 01/13/2015 06:26 AM, Daniel Borkmann wrote:
...
>> Anyway, extending Documentation/networking/packet_mmap.txt with
>> API details/examples at least for a non-RFC version is encouraged. ;)
>
> Yep for the non-RFC version I'll add an example to packet_mmap.txt

Cool, alternatively, perhaps a mini library under samples/packet/
would work, similarly as we have with samples/bpf/ which would allow
for a simple starting point for users to rx/tx frames.
