From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Wed, 28 Sep 2016 16:30:16 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB010AAC6@AcuExch.aculab.com>
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com> <57E55CBB.5060309@akamai.com>
 <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
 <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
 <20160927214229.2b0b49ac@roar.ozlabs.ibm.com>
 <92d1ec2c-3246-bd1f-eae5-53ca425ab315@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>,
	'Alexander Viro' <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	'Michal Hocko' <mhocko@kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: 'Vlastimil Babka' <vbabka@suse.cz>, Nicholas Piggin <npiggin@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <92d1ec2c-3246-bd1f-eae5-53ca425ab315@suse.cz>
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Vlastimil Babka
> Sent: 27 September 2016 12:51
...
> Process name suggests it's part of db2 database. It seems it has to imple=
ment
> its own interface to select() syscall, because glibc itself seems to have=
 a
> FD_SETSIZE limit of 1024, which is probably why this wasn't an issue for =
all the
> years...

ISTR the canonical way to increase the size being to set FD_SETSIZE
to a larger value before including any of the headers.

Or doesn't that work with linux and glibc ??

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
