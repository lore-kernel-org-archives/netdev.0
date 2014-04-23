From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 23 Apr 2014 13:29:55 -0400 (EDT)
Message-ID: <20140423.132955.671992126955940387.davem@davemloft.net>
References: <20140416002010.GA5035@redhat.com>
	<CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
	<20140423164537.GD24651@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, tj@kernel.org, dwalsh@redhat.com,
	linux-kernel@vger.kernel.org, lpoetter@redhat.com,
	ssorce@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	netdev@vger.kernel.org
To: vgoyal@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140423164537.GD24651@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivek Goyal <vgoyal@redhat.com>
Date: Wed, 23 Apr 2014 12:45:37 -0400

> On Tue, Apr 15, 2014 at 08:47:54PM -0700, Andy Lutomirski wrote:
> 
> [..]
>> Here's an attack against SO_PASSCGROUP, as you implemented it: connect
>> a socket and get someone else to write(2) to it.  This isn't very
>> hard.  Now you've impersonated.
> 
> If this is a problem then I think kernel requires fixing. Because kernel
> will apply all resource management policies based on the cgroup at write(2)
> time and not based on open() time.

Anyways, this is not even worth discussing.

We already agreed that the cgroup passed at write time with SO_PASSGROUP
enabled should be the socket creation time cgroup.

Just like SO_PASSCRED does.

The identity given is thus the one at open() time.
