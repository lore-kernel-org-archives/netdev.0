From: Reiner Herrmann <reiner.herrmann@sophos.com>
Subject: Re: low vxlan throughput with tso enabled
Date: Wed, 4 Feb 2015 13:42:24 +0100
Message-ID: <93bef28b-0983-48cc-bbd1-06d2c49dad1e@DE-WIE-EXCH3A.green.sophos>
References: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos> <54D0F8FF.1090204@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <svens@stackframe.org>,
	Vittorio Curcio <Vittorio.Curcio@Sophos.com>
To: Rick Jones <rick.jones2@hp.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.sophos.com ([145.253.124.138]:49566 "EHLO mx2.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933264AbbBDMmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 07:42:31 -0500
In-Reply-To: <54D0F8FF.1090204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2015 05:36 PM, Rick Jones wrote:
> I've been under the impression that one generally wants the MTU of a tunnel interface to be no more than the MTU of the physical interface over which it runs, less the 
> size of the encapsulation headers used by the tunnel.  What happens when you make the MTU of the tunnel interface 1400 bytes instead of 1500?
Lowering the MTU also brings throughput back to normal, but I'm interested in
why disabling TSO also seems to help (even with the same MTU).
