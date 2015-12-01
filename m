From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: ipsec impact on performance
Date: Tue, 1 Dec 2015 10:50:31 -0800
Message-ID: <565DEBF7.7040304@hpe.com>
References: <20151201175953.GC21252@oracle.com> <565DE446.2070609@hpe.com>
 <20151201184504.GF21252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151201184504.GF21252@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2015 10:45 AM, Sowmini Varadhan wrote:
> On (12/01/15 10:17), Rick Jones wrote:
>>
>> What do the perf profiles show?  Presumably, loss of TSO/GSO means
>> an increase in the per-packet costs, but if the ipsec path
>> significantly increases the per-byte costs...
>
> For ESP-null, there's actually very little work to do - we just
> need to add the 8 byte ESP header with an spi and a seq#.. no
> crypto work to do.. so the overhead *should* be minimal, else
> we've painted ourself into a corner where we can't touch anything
> including TCP options like md5.

Something of a longshot, but are you sure you are still getting 
effective CKO/GRO on the receiver?

rick jones
