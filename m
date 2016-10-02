From: Helge Deller <deller@gmx.de>
Subject: Re: rhashtable - rhashtable_insert_fast failed
Date: Sun, 2 Oct 2016 11:49:24 +0200
Message-ID: <57F0D824.9090406@gmx.de>
References: <5751E702.5040909@gmx.de> <20160604073527.GE29740@orbyte.nwl.cc>
 <20160606035718.GA19559@gondor.apana.org.au> <5756D69E.1080402@gmx.de>
 <20160607141656.GB2237@gondor.apana.org.au> <5756DE80.4040705@gmx.de>
 <20160608023957.GA12209@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Thomas Graf <tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:49410 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750831AbcJBJtl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Oct 2016 05:49:41 -0400
In-Reply-To: <20160608023957.GA12209@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On 08.06.2016 04:39, Herbert Xu wrote:
> On Tue, Jun 07, 2016 at 04:47:28PM +0200, Helge Deller wrote:
>> On 07.06.2016 16:16, Herbert Xu wrote:
>>> On Tue, Jun 07, 2016 at 04:13:50PM +0200, Helge Deller wrote:
>>>>
>>>> What warnings do you mean specifically? Some specific CONFIG_ option ?
>>>
>>> Look for GFP_NOWARN in lib/rhashtable.c and delete it.
>>
>> Ok, removed it.
>> It generates a kernel warning: 
> 
> Thanks.  This is exactly the problem that I'm yet to fix, namely
> we're trying to allocate a hash table that's too big to be done
> using physically contiguous memory.

I'm still seeing this problem with v4.8-rc8

Helge
