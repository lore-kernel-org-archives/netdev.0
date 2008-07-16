From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 09:00:07 -0500
Message-ID: <487DFEE7.4030308@bellsouth.net>
References: <487CD7A7.2080800@jeffray.co.uk> <487D893A.5080207@cosmosbay.com>	 <487DA388.3030104@jeffray.co.uk> <487DBA74.3090800@cosmosbay.com>	 <487DF9EC.9060202@bellsouth.net> <84144f020807160641u32dac56fq9b9a30f6e32a27ca@mail.gmail.com>
Reply-To: jacliburn@bellsouth.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Ian Jeffray <ian@jeffray.co.uk>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	csnook@redhat.com, jeff@garzik.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:4896 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757496AbYGPOAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 10:00:15 -0400
Received: by qw-out-2122.google.com with SMTP id 3so297354qwe.37
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 07:00:14 -0700 (PDT)
In-Reply-To: <84144f020807160641u32dac56fq9b9a30f6e32a27ca@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Enberg wrote:
> On Wed, Jul 16, 2008 at 4:38 PM, J. K. Cliburn <jcliburn@gmail.com> wrote:
>>> Yes, maybe related to commit 9d90fb1ac9d97da86e24d9ea947bf2a2f333829a
>>> In this patch, Jay Cliburn enabled TSO by default for atl1 driver.
>>>
>>> This might be a driver problem, or a generic sendfile() problem, I dont
>>> know...
>> I'm currently traveling and unable to delve into this issue and its relation
>> to the atl1 driver.  I should be able to look at it this weekend when I get
>> back home.
> 
> Ehh... shouldn't we disable atl1 TSO by default for -stable, then?

Based upon my inability to look at the problem for a couple more days?



