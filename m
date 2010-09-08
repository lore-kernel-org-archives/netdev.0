From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netlink: Fix kfree NULL pointer
Date: Wed, 08 Sep 2010 07:55:24 +0200
Message-ID: <1283925324.2634.843.camel@edumazet-laptop>
References: <AANLkTikp0m8cQYfEBHP_E8XpGZqdMj6Cr4M=aWCnei=X@mail.gmail.com>
	 <1283923185.2634.772.camel@edumazet-laptop>
	 <AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jovi zhang <bookjovi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim+=vj+k3=1hzT3=J4ssOopp5Eq=g+DHis=pZFN@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 08 septembre 2010 =C3=A0 13:33 +0800, jovi zhang a =C3=A9cr=
it :

> YES, maybe kfree(NULL) is legal, but I cannot see there have any need
> to invoke kfree(NULL) in this function.
>  Also I check kfree usage in other code, I havn't find any kfree(NULL=
) usage.

We have hundred call sites doing kfree(NULL), if it makes code shorter.

Its usually code path handling exceptions (errors if you prefer), and w=
e
prefer to use ugly gotos, and even kfree(NULL), to make it as short as
possible.
