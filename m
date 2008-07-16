From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 16:41:33 +0300
Message-ID: <84144f020807160641u32dac56fq9b9a30f6e32a27ca@mail.gmail.com>
References: <487CD7A7.2080800@jeffray.co.uk> <487D893A.5080207@cosmosbay.com>
	 <487DA388.3030104@jeffray.co.uk> <487DBA74.3090800@cosmosbay.com>
	 <487DF9EC.9060202@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Ian Jeffray" <ian@jeffray.co.uk>, linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>, csnook@redhat.com,
	jeff@garzik.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:49406 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605AbYGPNle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 09:41:34 -0400
Received: by rv-out-0506.google.com with SMTP id k40so6421597rvb.1
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 06:41:33 -0700 (PDT)
In-Reply-To: <487DF9EC.9060202@bellsouth.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 4:38 PM, J. K. Cliburn <jcliburn@gmail.com> wrote:
>> Yes, maybe related to commit 9d90fb1ac9d97da86e24d9ea947bf2a2f333829a
>> In this patch, Jay Cliburn enabled TSO by default for atl1 driver.
>>
>> This might be a driver problem, or a generic sendfile() problem, I dont
>> know...
>
> I'm currently traveling and unable to delve into this issue and its relation
> to the atl1 driver.  I should be able to look at it this weekend when I get
> back home.

Ehh... shouldn't we disable atl1 TSO by default for -stable, then?
