From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: net: netlink executing RO memory
Date: Fri, 06 Jun 2014 01:45:21 -0400
Message-ID: <53915571.7050801@oracle.com>
References: <5390D152.30702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5390D152.30702@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2014 04:21 PM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew:
> 
> [  306.065161] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
> [  306.067295] BUG: unable to handle kernel paging request at ffff880053b8fd08

Same issue reproduced multiple times with exactly the same trace, so I think that it
rules out random memory corruption.


Thanks,
Sasha
