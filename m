From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 20:34:55 +0100
Message-ID: <41C334DF.107@dbservice.com>
References: <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com>	<41C2DCBC.1080302@dbservice.com> <20041217111634.740d4d46.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, kaber@trash.net, bryan@coverity.com,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041217111634.740d4d46.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 17 Dec 2004 14:18:52 +0100
> Tomas Carnecky <tom@dbservice.com> wrote:
> 
> 
>>IMHO such things (passing values between user/kernel space) should 
>>always be checked.
> 
> 
> As per Patrick's posting, which James was responding to, it is
> checked at the level above this function.

Is only the capability checked or also the data passed to the kernel?
It's not clear from Patricks reply:
 > It is already checked in do_ip6t_set_ctl(). Otherwise anyone could
 > replace iptables rules :)
For me it seems that only CAP_NET_ADMIN is checked and not the data.

tom
