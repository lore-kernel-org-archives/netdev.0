From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: ethernet QoS support?
Date: Fri, 9 Jul 2004 10:46:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <2290273A-D1BF-11D8-B72C-000393DBC2E8@freescale.com>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <40ED9A1C.4040707@pobox.com> <1089316845.1072.1.camel@jzny.localdomain> <200407091002.26410.vkondra@mail.ru>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <hadi@cyberus.ca>, Kumar Gala <kumar.gala@motorola.com>,
        <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <200407091002.26410.vkondra@mail.ru>
To: Vladimir Kondratiev <vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Jul 9, 2004, at 2:02 AM, Vladimir Kondratiev wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> I guess, Kumar is asking for support for several Tx queues with 
> different
> priorities. One need to start/stop these queues separately. This is 
> dictated
> by presense of different priorities on physical layer.
>
> Kumar, is it 802.11? WME or TGE?

I'm not sure what WME or TGE stand for, we are looking at a gig-e 
controller.

>
> Vladimir.
>
> On Thursday 08 July 2004 23:00, jamal wrote:
>> On Thu, 2004-07-08 at 15:01, Jeff Garzik wrote:
>>> Kumar Gala wrote:
>>>> Jeff,
>>>>
>>>> I was wondering if there was any support for handling ethernet 
>>>> devices
>>>> that support multiple RX/TX queues to provide QoS.  If so any 
>>>> pointers
>>>> would be great.
>>>
>>> IIRC skb->priority provides priority bands for TX.  Not sure about 
>>> RX...
>>> jamal?
>>
>> The question was very ambigous.
>> What is it that Kumar is looking for? Is it 802.1p, IP level etc?
>>
>> cheers,
>> jamal
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.4 (GNU/Linux)
>
> iD8DBQFA7kMCqxdj7mhC6o0RAkeKAJ96kf49fbVy4qOjqqBBuNzmCteTrQCfU55Q
> ke3RQ2prgMLEssvjeQIgegs=
> =/KHu
> -----END PGP SIGNATURE-----
