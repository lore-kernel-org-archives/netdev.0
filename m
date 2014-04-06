From: "Phoebe Buckheister" <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: Re: nl802154 UAPI definitions
Date: Mon, 7 Apr 2014 00:43:01 +0200
Message-ID: <acff4139b1286a0c047ffb3001d2e0b5.squirrel@webmail.itwm.fhg.de>
References: <1396271873-10300-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1396271873-10300-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1396822935.13361.9.camel@deadeye.wl.decadent.org.uk>
Reply-To: phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "Ben Hutchings" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1396822935.13361.9.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, April 7, 2014 12:22 am, Ben Hutchings wrote:
> On Mon, 2014-03-31 at 15:17 +0200, Phoebe Buckheister wrote:
> [...]
>> --- a/include/linux/nl802154.h
>> +++ b/include/linux/nl802154.h
>> @@ -132,7 +132,7 @@ enum {
>>  	IEEE802154_ADD_IFACE,
>>  	IEEE802154_DEL_IFACE,
>>
>> -	IEEE802154_SET_PHYPARAMS,
>> +	IEEE802154_SET_MACPARAMS,
>>
>>  	__IEEE802154_CMD_MAX,
>>  };
> [...]
>
> By the way, this header file belongs in include/uapi/linux (except for
> the ieee802154_policy declaration).

Yes, I've talked about that with other 802154 devs a few times as well. No
kernel until 3.15 will have had a 802.15.4 stack that's seriously usable,
whether at all or in compliance with regulations, do to an impressive list
of bugs and missing control knobs. I'd suggest to move all user-relevant
API descriptions to uapi/ once all that is sorted out to signify that the
stack is now somewhat usable beyond the toy examples of sending and
receiving five packets or so. (For example, before 3.15, anything 6lowpan
might crash the kernel, and opening 802.15.4 sockets while a 6lowpan
device *exists* will crash the machine hard. Unfortunately, byte ordering
in the APIs will stay with us nonetheless.)


------------------------------------------------------------------------------
