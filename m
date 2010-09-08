From: jovi zhang <bookjovi@gmail.com>
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Wed, 8 Sep 2010 14:14:42 +0800
Message-ID: <AANLkTikfhz4AQntX2o5sSQy67TWb=rYqEjsoA2ju+Ycq@mail.gmail.com>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
	<1283923185.2634.772.camel@edumazet-laptop>
	<AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
	<1283925324.2634.843.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283925324.2634.843.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 8, 2010 at 1:55 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 08 septembre 2010 =C3=A0 13:33 +0800, jovi zhang a =C3=A9=
crit :
>
>> YES, maybe kfree(NULL) is legal, but I cannot see there have any nee=
d
>> to invoke kfree(NULL) in this function.
>> =C2=A0Also I check kfree usage in other code, I havn't find any kfre=
e(NULL) usage.
>
> We have hundred call sites doing kfree(NULL), if it makes code shorte=
r.
>
> Its usually code path handling exceptions (errors if you prefer), and=
 we
> prefer to use ugly gotos, and even kfree(NULL), to make it as short a=
s
> possible.

OK, I understand.
