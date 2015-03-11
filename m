From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Wed, 11 Mar 2015 23:01:00 +0300
Message-ID: <CAPAsAGwuCzzDCgiNd=LrHA_W1Nj5TJu3Qym9tR3jnGdT45HQuw@mail.gmail.com>
References: <55004595.7020304@oracle.com>
	<20150311.132052.205877953171712952.davem@davemloft.net>
	<55007A9B.4010608@oracle.com>
	<20150311.144443.1290707334236248572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sasha Levin <sasha.levin@oracle.com>, rostedt@goodmis.org,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150311.144443.1290707334236248572.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2015-03-11 21:44 GMT+03:00 David Miller <davem@davemloft.net>:
> From: Sasha Levin <sasha.levin@oracle.com>
> Date: Wed, 11 Mar 2015 13:25:47 -0400
>
>> You're probably wondering why there are changes to SPARC in that patchset? :)
>
> Libsanitizer doesn't even build have the time on sparc, the release
> manager has to hand patch it into building again every major release
> because of the way ASAN development is done out of tree and local
> commits to the gcc tree are basically written over during the
> next merge.
>

Libsanitizer is userspace lib it's for userspace ASan, KASan doesn't use it.
We have our own 'libsanitzer' in kernel.

> So I'm a little bit bitter about this, as you can see. :)
>


-- 
Best regards,
Andrey Ryabinin
