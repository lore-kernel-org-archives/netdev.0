From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH v2 1/4] net: add name_assign_type netdev attribute
Date: Sun, 16 Mar 2014 22:53:48 +0100
Message-ID: <CANq1E4R8WAWu5_V+_D_8e+u0hmhayi4Ueh7pDwcbvGwp=KTRBw@mail.gmail.com>
References: <1394990490-1076-1-git-send-email-dh.herrmann@gmail.com>
	<1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
	<1394997429.15764.116.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394997429.15764.116.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Sun, Mar 16, 2014 at 8:17 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sun, 2014-03-16 at 18:21 +0100, David Herrmann wrote:
> [...]
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -74,6 +74,11 @@ void netdev_set_default_ethtool_ops(struct net_device *dev,
>>  #define NET_RX_SUCCESS               0       /* keep 'em coming, baby */
>>  #define NET_RX_DROP          1       /* packet dropped */
>>
>> +/* interface name assignment types */
>> +#define NET_NAME_ENUM                0       /* enumerated by kernel (default) */
>> +#define NET_NAME_USER                1       /* provided by user-space */
>> +#define NET_NAME_RENAMED     2       /* renamed by user-space */
> [...]
>
> I think these definitions should be put in a UAPI header.  Even if the
> names don't end up being used by userland, that would make it clear that
> the numbers are a stable ABI.

I tried to follow addr_assign_type as closely as possible. The
NET_ADDR_* constants are only defined internally either. I am fine
with exporting the constants, just want to make sure there's no reason
to hide them that I'm not aware of.

Thanks
David
