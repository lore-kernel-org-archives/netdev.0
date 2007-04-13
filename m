From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 11:09:52 +0400
Message-ID: <20070413070951.GB2138@2ka.mipt.ru>
References: <461D2DEA.4010806@candelatech.com> <461D447C.4070408@candelatech.com> <20070411.134804.50594117.davem@davemloft.net> <461D4DD7.7020207@candelatech.com> <p73y7kx7iol.fsf@bingen.suse.de> <461E7377.3020708@candelatech.com> <20070412201940.7f570b6d.dada1@cosmosbay.com> <461E8496.2050003@candelatech.com> <461E998A.8080409@cosmosbay.com> <461EA662.5090801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37411 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbXDMHLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 03:11:51 -0400
Content-Disposition: inline
In-Reply-To: <461EA662.5090801@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 12, 2007 at 02:36:34PM -0700, Ben Greear (greearb@candelatech.com) wrote:
> I am not sure if the problem is fixed or just harder to hit,
> but for now it looks good.

Wasn't default congestion control algo changed between that kernel
releases?
With such small rtt like in your setup there could be some obscure bug,
try to set different one and check if it still works good/bad.

-- 
	Evgeniy Polyakov
