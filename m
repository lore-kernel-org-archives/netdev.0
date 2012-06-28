From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 0/4] net: introduce and use IFF_LIFE_ADDR_CHANGE
Date: Thu, 28 Jun 2012 17:41:09 +0200
Message-ID: <20120628154109.GG1520@minipsycho.orion>
References: <1340892639-1111-1-git-send-email-jpirko@redhat.com>
	<20120628151507.GA5920@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, shimoda.hiroaki@gmail.com,
	virtualization@lists.linux-foundation.org,
	danny.kukawka@bisect.de, edumazet@google.com, davem@davemloft.net
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120628151507.GA5920@localhost.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Thu, Jun 28, 2012 at 05:15:07PM CEST, richardcochran@gmail.com wrote:
>On Thu, Jun 28, 2012 at 04:10:35PM +0200, Jiri Pirko wrote:
>> three drivers updated, but this can be used in many others.
>> 
>> Jiri Pirko (4):
>>   net: introduce new priv_flag indicating iface capable of change mac
>>     when running
>>   virtio_net: use IFF_LIFE_ADDR_CHANGE priv_flag
>>   team: use IFF_LIFE_ADDR_CHANGE priv_flag
>>   dummy: use IFF_LIFE_ADDR_CHANGE priv_flag
>
>I think you must mean LIVE and not LIFE...

Good point. I will change it and repost, but I will give it some time so
people can express themselves.

Thanks!

Jirka
>
>Thanks,
>Richard
>
>
>> 
>>  drivers/net/dummy.c      |   15 ++-------------
>>  drivers/net/team/team.c  |    9 +++++----
>>  drivers/net/virtio_net.c |   11 +++++------
>>  include/linux/if.h       |    2 ++
>>  net/ethernet/eth.c       |    2 +-
>>  5 files changed, 15 insertions(+), 24 deletions(-)
>> 
>> -- 
>> 1.7.10.4
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
