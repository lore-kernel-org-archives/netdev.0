From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Tue, 07 Sep 2010 22:54:52 -0700
Message-ID: <m1tym0vkyb.fsf@fess.ebiederm.org>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
	<1283923185.2634.772.camel@edumazet-laptop>
	<AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jovi zhang <bookjovi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
	(jovi zhang's message of "Wed, 8 Sep 2010 13:33:28 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jovi zhang <bookjovi@gmail.com> writes:

> On Wed, Sep 8, 2010 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>
>>
>> This patch is not needed
>>
>> kfree(NULL) is legal
>>
>>
>>
>>
>
> YES, maybe kfree(NULL) is legal, but I cannot see there have any need
> to invoke kfree(NULL) in this function.
> =C2=A0Also I check kfree usage in other code, I havn't find any kfree=
(NULL)
> usage.

Usually kfree(NULL) is not explicit, but "var =3D NULL; kfree(var)" is
common in error handling paths to reduce the complexity of error
handling, making bugs less likely.


Eric
