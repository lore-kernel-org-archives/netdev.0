From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Fri, 28 Aug 2015 14:19:56 -0700
Message-ID: <CAHA+R7Mv=-QoeRuY1nPEV55o5MMekeW+GqOuU+dh18a_5+iYOg@mail.gmail.com>
References: <6112e6ccb97c5015b6f8125d8c0f75c179b53198.1440689853.git.pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Philip Downey <pdowney@brocade.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6112e6ccb97c5015b6f8125d8c0f75c179b53198.1440689853.git.pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 27, 2015 at 8:46 AM, Philip Downey <pdowney@brocade.com> wrote:
> IGMP reports for local multicast groups can now be optionally
> inhibited by means of a system control variable (by setting the value
> to zero) e.g.:
>     echo 0 > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
>
> To retain backwards compatibility the previous behaviour is retained
> by default on system boot or reverted by setting the value back to
> non-zero e.g.:
>     echo 1 >  /proc/sys/net/ipv4/igmp_link_local_mcast_reports
>

Please document it in Documentation/networking/ip-sysctl.txt.
