From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 1/6] cxgb4: Add register, message, and FW definitions
Date: Tue, 30 Mar 2010 18:25:56 -0700
Message-ID: <4BB2A4A4.8050904@chelsio.com>
References: <1269975142-30896-1-git-send-email-dm@chelsio.com>	<1269975142-30896-2-git-send-email-dm@chelsio.com> <20100330140928.3a9c3f34@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11740 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756431Ab0CaB0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 21:26:00 -0400
In-Reply-To: <20100330140928.3a9c3f34@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 10:52:17 -0800
> Dimitris Michailidis <dm@chelsio.com> wrote:
> 
>> +union opcode_tid {
>> +	__be32 opcode_tid;
>> +	__u8 opcode;
>> +};
>> +
> 
> The intent of the __types like __u8 etc are that these types
> should only be used by structures that are part in some way of
> a kernel to userspace API. Any structures which are only used
> in the kernel should just use the regular type (ie u8).
> 
> I say intent because many places do not follow this practice.
> 

These headers aren't meant to be seen by user space and I can certainly 
replace __u8 with u8.  I'll update the patch.
