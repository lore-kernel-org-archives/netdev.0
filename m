From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: TCP MD5 and Scatter Gather offloading.
Date: Wed, 25 Jul 2007 15:32:30 -0400
Message-ID: <46A7A54E.4000608@redhat.com>
References: <526ad3230707251012r25188175g5fa460fe90ca9d61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Siddharth Taneja <siddharth.taneja@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752692AbXGYTcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 15:32:32 -0400
In-Reply-To: <526ad3230707251012r25188175g5fa460fe90ca9d61@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/25/2007 01:12 PM, Siddharth Taneja wrote:

[cc: netdev]

> Hello,
> 
> I am using a vanilla 2.6.22.1 kernel and I see the same kind of
> problem as had been mentioned some time back on this list
> 
> http://lkml.org/lkml/2007/5/22/45
> 
> The issue is essentially that with the MD5 option enabled for the
> specific TCP connection, the SYN and SYN-ACKS are passed fine and the
> connection establishes fine, but the other end (a cisco router)
> complains about incorrect MD5 signatures on any other message that is
> sent after this.
> 
> Setting the scatter-gather offloading option on the NIC seems to
> correct this problem. Recently I had seen a checkin (as a response to
> the problem mentioned in the above link) where the TSO option was
> turned off to make MD5 work (my kernel has that fix). Is a similar
> solution needed here too?
> 
> This is the information about my system:
>> uname -a
> Linux stdalone 2.6.22.1 #1 SMP Mon Jul 23 20:15:21 PDT 2007 i686 i686
> i386 GNU/Linux
> 
>> ethtool -i eth0
> driver: e1000
> version: 7.3.20-k2
> firmware-version: N/A
> bus-info: 0000:01:0a.0
> 
>> ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: off
> tcp segmentation offload: off
> 
> Thanks for your help.
> 
> Siddharth
> 
> PS: I would like to be CC'ed on the reply to this email. Thanks.
