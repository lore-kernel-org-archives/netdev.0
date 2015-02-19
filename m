From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v5 4/6] bonding: Allow userspace to set actors' system_priority
 in AD system
Date: Thu, 19 Feb 2015 01:13:18 +0100
Message-ID: <54E52A9E.10003@redhat.com>
References: <1424298685-18394-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45179 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbbBSAN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 19:13:29 -0500
In-Reply-To: <1424298685-18394-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 11:31 PM, Mahesh Bandewar wrote:
> This patch allows user to randomize the system-priority in an ad-system.
> The allowed range is 1 - 0xFFFF while default value is 0xFFFF. If user
> does not specify this value, the system defaults to 0xFFFF, which is
> what it was before this patch.
> 
> Following example code could set the value -
>     # modprobe bonding mode=4
>     # sys_prio=$(( 1 + RANDOM + RANDOM ))
>     # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio
>     # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>     ...
>     # ip link set bond0 up
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   Initial version
> v2:
>   Rename ad_actor_system_priority to ad_actor_sys_prio
> v3-v4:
>   Rebase
> v5:
>   Cosmetic changes
> 
>  Documentation/networking/bonding.txt |  9 +++++++++
>  drivers/net/bonding/bond_3ad.c       |  5 ++++-
>  drivers/net/bonding/bond_main.c      | 14 ++++++++++++++
>  drivers/net/bonding/bond_options.c   | 29 ++++++++++++++++++++++++++++-
>  drivers/net/bonding/bond_procfs.c    |  2 ++
>  drivers/net/bonding/bond_sysfs.c     | 15 +++++++++++++++
>  include/net/bond_options.h           |  1 +
>  include/net/bonding.h                |  1 +
>  8 files changed, 74 insertions(+), 2 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
