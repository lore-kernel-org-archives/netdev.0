From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 16:48:07 -0400 (EDT)
Message-ID: <20150311.164807.1389597491151339402.davem@davemloft.net>
References: <55007A9B.4010608@oracle.com>
	<20150311.144443.1290707334236248572.davem@davemloft.net>
	<CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
To: ryabinin.a.a@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Date: Wed, 11 Mar 2015 23:01:00 +0300

> 2015-03-11 21:44 GMT+03:00 David Miller <davem@davemloft.net>:
>> From: Sasha Levin <sasha.levin@oracle.com>
>> Date: Wed, 11 Mar 2015 13:25:47 -0400
>>
>>> You're probably wondering why there are changes to SPARC in that patchset? :)
>>
>> Libsanitizer doesn't even build have the time on sparc, the release
>> manager has to hand patch it into building again every major release
>> because of the way ASAN development is done out of tree and local
>> commits to the gcc tree are basically written over during the
>> next merge.
>>
> 
> Libsanitizer is userspace lib it's for userspace ASan, KASan doesn't use it.
> We have our own 'libsanitzer' in kernel.

I was speaking about ASAN development in general, of which the
libsanitizer issue is a byproduct.
