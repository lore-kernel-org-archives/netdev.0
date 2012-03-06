From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCHv 2] tcp: properly initialize tcp memory limits part 2
 (fix nfs regression)
Date: Tue, 06 Mar 2012 11:22:41 +0800
Message-ID: <4F558301.9000402@redhat.com>
References: <1330675173-18968-1-git-send-email-slyich@gmail.com> <4F509150.5060904@redhat.com> <20120302202421.753b36bc@sf.home> <20120302205000.088bf231@sf.home> <4F5227C9.7060209@parallels.com> <20120303174322.7e920bc5@sf.home> <4F52A8D5.9090703@parallels.com> <20120304121400.4d756e55@sf.home> <4F545AC3.50004@redhat.com> <20120305212206.43f3abfa@sf.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Sergei Trofimovich <slyich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120305212206.43f3abfa@sf.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/06/2012 02:22 AM, Sergei Trofimovich wrote:
>> This one looks small to me, as the tcp_{r,w}mem were count by bytes and
>> >  limit were count by number of pages, so we need to shift PAGE_SHIFT.
>> >  
>> >  As I can't reproduce this locally, in order to narrow down the problem,
>> >  could you please help to check whether the issue were
>> >  introduced/eliminated by commit  4acb4190 or 3dc43e3?
> I didn't think of server problem. I did run 3.3-rc0 kernel there
> from the kvm tree (v3.2-10396-g05ef4c6):
>      commit 05ef4c60568ed1740f65bf66a76da30b19060119
>      Author: Michael S. Tsirkin<mst@redhat.com>
>      Date:   Wed Jan 18 20:07:09 2012 +0200
>
>          kvm: fix error handling for out of range irq
>
>      from git://git.kernel.org/pub/scm/virt/kvm/kvm.git
>
> Updating to current vanilla 3.3-rc6 solved the problem.
> Are you interested in digging that issue further to find commit
> breaking the server?
Hi Sergei:

So it's very possible that it's a bug which is blacklisted by early 
commits and uncovered by my commit ( 
c43b874d5d714f271b80d4c3f49e05d0cbf51ed2). I wish I can help in nfs 
debugging, but I'm not familiar with that.

thanks
