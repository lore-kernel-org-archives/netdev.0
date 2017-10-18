From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Thu, 19 Oct 2017 01:51:57 +0200
Message-ID: <d4d1c562-e976-1894-e36c-709fd319dfb2@itcare.pl>
References: <1507121766.30720.4.camel@cohaesio.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
 <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
 <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
 <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl>
 <f6e2208a-4cdf-3303-5999-92186b437b62@itcare.pl>
 <1704eb26-c4c5-b196-ca7a-5265e92ae4e6@itcare.pl>
 <bd82f85a-f9b8-a09a-beab-67667b58f36a@itcare.pl>
 <7fd828d7-c586-2c32-3ba6-e0575bf9958c@itcare.pl>
 <99eba19f-327e-e01f-4f4a-87540b176e40@itcare.pl>
 <efcc51b4-f911-11ec-1c56-fcf31081f9d5@itcare.pl>
 <d79df7f2-5de4-cc37-baf0-5603f025155e@itcare.pl>
 <748b6d9d-4a3f-4eaa-ad24-27060c2e2642@itcare.pl>
 <16c9fa34-252f-e5a3-8b15-e5a8c4d8a46f@itcare.pl>
 <12670bc6-439c-7ef4-109a-fd20384b9ca2@itcare.pl>
 <bd59ccc3-2af4-6842-8d2f-169229a61470@itcare.pl>
 <888ec430-1d70-68e6-2ee8-bab53d21bb0f@itcare.pl>
 <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Pavlos Parissis <pavlos.parissis@gmail.com>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp52.iq.pl ([86.111.240.252]:60748 "EHLO smtp52.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750829AbdJRXwA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 19:52:00 -0400
In-Reply-To: <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-10-19 o 01:37, Alexander Duyck pisze:
> On Wed, Oct 18, 2017 at 4:22 PM, Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>>
>> W dniu 2017-10-19 o 00:58, Paweł Staszewski pisze:
>>
>>>
>>> W dniu 2017-10-19 o 00:50, Paweł Staszewski pisze:
>>>>
>>>>
>>>> W dniu 2017-10-19 o 00:20, Paweł Staszewski pisze:
>>>>>
>>>>>
>>>>> W dniu 2017-10-18 o 17:44, Paweł Staszewski pisze:
>>>>>>
>>>>>>
>>>>>> W dniu 2017-10-17 o 16:08, Paweł Staszewski pisze:
>>>>>>>
>>>>>>>
>>>>>>> W dniu 2017-10-17 o 13:52, Paweł Staszewski pisze:
>>>>>>>>
>>>>>>>>
>>>>>>>> W dniu 2017-10-17 o 13:05, Paweł Staszewski pisze:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> W dniu 2017-10-17 o 12:59, Paweł Staszewski pisze:
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> W dniu 2017-10-17 o 12:51, Paweł Staszewski pisze:
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> W dniu 2017-10-17 o 12:20, Paweł Staszewski pisze:
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> W dniu 2017-10-17 o 11:48, Paweł Staszewski pisze:
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>> W dniu 2017-10-17 o 02:44, Paweł Staszewski pisze:
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>>> W dniu 2017-10-17 o 01:56, Alexander Duyck pisze:
>>>>>>>>>>>>>>> On Mon, Oct 16, 2017 at 4:34 PM, Paweł Staszewski
>>>>>>>>>>>>>>> <pstaszewski@itcare.pl> wrote:
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> W dniu 2017-10-16 o 18:26, Paweł Staszewski pisze:
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
>>>>>>>>>>>>>>>>>> On 15/10/2017 02:58 πμ, Alexander Duyck wrote:
>>>>>>>>>>>>>>>>>>> Hi Pawel,
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> To clarify is that Dave Miller's tree or Linus's that you
>>>>>>>>>>>>>>>>>>> are talking
>>>>>>>>>>>>>>>>>>> about? If it is Dave's tree how long ago was it you pulled
>>>>>>>>>>>>>>>>>>> it since I
>>>>>>>>>>>>>>>>>>> think the fix was just pushed by Jeff Kirsher a few days
>>>>>>>>>>>>>>>>>>> ago.
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> The issue should be fixed in the following commit:
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=2b9478ffc550f17c6cd8c69057234e91150f5972
>>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>> Do you know when it is going to be available on net-next
>>>>>>>>>>>>>>>>>> and linux-stable
>>>>>>>>>>>>>>>>>> repos?
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>> Cheers,
>>>>>>>>>>>>>>>>>> Pavlos
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>> I will make some tests today night with "net" git tree where
>>>>>>>>>>>>>>>>> this patch is
>>>>>>>>>>>>>>>>> included.
>>>>>>>>>>>>>>>>> Starting from 0:00 CET
>>>>>>>>>>>>>>>>> :)
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Upgraded and looks like problem is not solved with that patch
>>>>>>>>>>>>>>>> Currently running system with
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/
>>>>>>>>>>>>>>>> kernel
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Still about 0.5GB of memory is leaking somewhere
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> Also can confirm that the latest kernel where memory is not
>>>>>>>>>>>>>>>> leaking (with
>>>>>>>>>>>>>>>> use i40e driver intel 710 cards) is 4.11.12
>>>>>>>>>>>>>>>> With kernel 4.11.12 - after hour no change in memory usage.
>>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>>> also checked that with ixgbe instead of i40e with same
>>>>>>>>>>>>>>>> net.git kernel there
>>>>>>>>>>>>>>>> is no memleak - after hour same memory usage - so for 100%
>>>>>>>>>>>>>>>> this is i40e
>>>>>>>>>>>>>>>> driver problem.
>>>>>>>>>>>>>>> So how long was the run to get the .5GB of memory leaking?
>>>>>>>>>>>>>> 1 hour
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Also is there any chance of you being able to bisect to
>>>>>>>>>>>>>>> determine
>>>>>>>>>>>>>>> where the memory leak was introduced since as you pointed out
>>>>>>>>>>>>>>> it
>>>>>>>>>>>>>>> didn't exist in 4.11.12 so odds are it was introduced
>>>>>>>>>>>>>>> somewhere
>>>>>>>>>>>>>>> between 4.11 and the latest kernel release.
>>>>>>>>>>>>>> Can be hard cause currently need to back to 4.11.12 - this is
>>>>>>>>>>>>>> production host/router
>>>>>>>>>>>>>> Will try to find some free/test router for tests/bicects with
>>>>>>>>>>>>>> i40e driver (intel 710 cards)
>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> Thanks.
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>> - Alex
>>>>>>>>>>>>>>>
>>>>>>>>>>>>>>
>>>>>>>>>>>>> Also forgoto to add errors for i40e when driver initialize:
>>>>>>>>>>>>> [   15.760569] i40e 0000:02:00.1: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.365587] i40e 0000:03:00.3: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.367686] i40e 0000:02:00.2: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.368816] i40e 0000:03:00.0: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.369877] i40e 0000:03:00.2: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.370941] i40e 0000:02:00.3: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.372005] i40e 0000:02:00.0: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>> [   16.373029] i40e 0000:03:00.1: Error I40E_AQ_RC_ENOSPC adding
>>>>>>>>>>>>> RX filters on PF, promiscuous mode forced on
>>>>>>>>>>>>>
>>>>>>>>>>>>> some params that are set for this nic's
>>>>>>>>>>>>>          ip link set up dev $i
>>>>>>>>>>>>>          ethtool -A $i autoneg off rx off tx off
>>>>>>>>>>>>>          ethtool -G $i rx 1024 tx 2048
>>>>>>>>>>>>>          ip link set $i txqueuelen 1000
>>>>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs
>>>>>>>>>>>>> 512 tx-usecs 128
>>>>>>>>>>>>>          ethtool -L $i combined 6
>>>>>>>>>>>>>          #ethtool -N $i rx-flow-hash udp4 sdfn
>>>>>>>>>>>>>          ethtool -K $i ntuple on
>>>>>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>>>>>          ethtool -K $i tso off
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>> Also after TSO/GRO on there is memory usage change - and leaking
>>>>>>>>>>>> faster
>>>>>>>>>>>> Below image from memory usage before change with TSO/GRO OFF and
>>>>>>>>>>>> after enabling TSO/GRO
>>>>>>>>>>>>
>>>>>>>>>>>> https://ibb.co/dTqBY6
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> Thanks
>>>>>>>>>>>> Pawel
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>> With settings like this:
>>>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1
>>>>>>>>>>> enp3s0f2 enp3s0f3'
>>>>>>>>>>> for i in $ifc
>>>>>>>>>>>          do
>>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 512
>>>>>>>>>>> tx-usecs 128
>>>>>>>>>>>          ethtool -K $i gro on
>>>>>>>>>>>          ethtool -K $i tso on
>>>>>>>>>>>
>>>>>>>>>>>          done
>>>>>>>>>>>
>>>>>>>>>>> Server is leaking about 4-6MB per each 10 seconds
>>>>>>>>>>> MEMLEAK:
>>>>>>>>>>> 5  MB/10sec
>>>>>>>>>>> 6  MB/10sec
>>>>>>>>>>> 4  MB/10sec
>>>>>>>>>>> 4  MB/10sec
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> Other settings TSO/GRO off
>>>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1
>>>>>>>>>>> enp3s0f2 enp3s0f3'
>>>>>>>>>>> for i in $ifc
>>>>>>>>>>>          do
>>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 512
>>>>>>>>>>> tx-usecs 128
>>>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>>>          ethtool -K $i tso off
>>>>>>>>>>>
>>>>>>>>>>>          done
>>>>>>>>>>>
>>>>>>>>>>> Same leak about 5MB per 10 seconds
>>>>>>>>>>> MEMLEAK:
>>>>>>>>>>> 5  MB/10sec
>>>>>>>>>>> 5  MB/10sec
>>>>>>>>>>> 5  MB/10sec
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> Other settings rx-usecs change from 512 to 1024:
>>>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1
>>>>>>>>>>> enp3s0f2 enp3s0f3'
>>>>>>>>>>> for i in $ifc
>>>>>>>>>>>          do
>>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs
>>>>>>>>>>> 1024 tx-usecs 128
>>>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>>>          ethtool -K $i tso off
>>>>>>>>>>>
>>>>>>>>>>>          done
>>>>>>>>>>>
>>>>>>>>>>> MEMLEAK:
>>>>>>>>>>> 4  MB/10sec
>>>>>>>>>>> 3  MB/10sec
>>>>>>>>>>> 4  MB/10sec
>>>>>>>>>>> 4  MB/10sec
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> So memleak have something to do with rx-usecs (less interrupts but
>>>>>>>>>>> bigger latency for traffic)
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> But also enabling TSO/GRO making leak about 1MB bigger for each 10
>>>>>>>>>>> seconds
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>> So far best config is:
>>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>>>>>>> enp3s0f3'
>>>>>>>>>> for i in $ifc
>>>>>>>>>>          do
>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 64
>>>>>>>>>> tx-usecs 512
>>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>>          ethtool -K $i tso on
>>>>>>>>>>
>>>>>>>>>>          done
>>>>>>>>>>
>>>>>>>>>> MEMLEAK - about 2MB/10secs
>>>>>>>>>> 2  MB/10sec
>>>>>>>>>> 2  MB/10sec
>>>>>>>>>> 2  MB/10sec
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> With - rx-usecs set to 256 (about 7-9MB/10secs memleak)
>>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>>>>>>> enp3s0f3'
>>>>>>>>>> for i in $ifc
>>>>>>>>>>          do
>>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 256
>>>>>>>>>> tx-usecs 512
>>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>>          ethtool -K $i tso on
>>>>>>>>>>
>>>>>>>>>>          done
>>>>>>>>>>
>>>>>>>>>> MEMLEAK:
>>>>>>>>>> 7  MB/10sec
>>>>>>>>>> 7  MB/10sec
>>>>>>>>>> 8  MB/10sec
>>>>>>>>>> 9  MB/10sec
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>> And even less memleak with rx-usecs set to 32
>>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>>>>>> enp3s0f3'
>>>>>>>>> for i in $ifc
>>>>>>>>>          do
>>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 32
>>>>>>>>> tx-usecs 512
>>>>>>>>>          ethtool -K $i gro off
>>>>>>>>>          ethtool -K $i tso on
>>>>>>>>>
>>>>>>>>>          done
>>>>>>>>>
>>>>>>>>>
>>>>>>>>> MEMLEAK - about 0-2MB for each 10 seconds
>>>>>>>>> 0  MB/10sec
>>>>>>>>> 1  MB/10sec
>>>>>>>>> 0  MB/10sec
>>>>>>>>> 2  MB/10sec
>>>>>>>>> 1  MB/10sec
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>>
>>>>>>>> So best settings - to have as less leak as possible for now (rx-usecs
>>>>>>>> set to 16):
>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>>>>> enp3s0f3'
>>>>>>>> for i in $ifc
>>>>>>>>          do
>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 16
>>>>>>>> tx-usecs 768
>>>>>>>>          ethtool -K $i gro on
>>>>>>>>          ethtool -K $i tso on
>>>>>>>>
>>>>>>>>          done
>>>>>>>>
>>>>>>>>
>>>>>>>> MEMLEAK: (0-1MB/10seconds)
>>>>>>>> 0  MB/10sec
>>>>>>>> 0  MB/10sec
>>>>>>>> 0  MB/10sec
>>>>>>>> 1  MB/10sec
>>>>>>>> 1  MB/10sec
>>>>>>>> -1  MB/10sec
>>>>>>>> 1  MB/10sec
>>>>>>>> 1  MB/10sec
>>>>>>>> 0  MB/10sec
>>>>>>>>
>>>>>>>> (there are some memory recycles - so this is good :) )
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> Compared to(rx-usecs 512):
>>>>>>>>
>>>>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>>>>> enp3s0f3'
>>>>>>>> for i in $ifc
>>>>>>>>          do
>>>>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 512
>>>>>>>> tx-usecs 128
>>>>>>>>          ethtool -K $i gro on
>>>>>>>>          ethtool -K $i tso on
>>>>>>>>
>>>>>>>>          done
>>>>>>>>
>>>>>>>> Server is leaking about 4-6MB per each 10 seconds
>>>>>>>> MEMLEAK:
>>>>>>>> 5  MB/10sec
>>>>>>>> 6  MB/10sec
>>>>>>>> 4  MB/10sec
>>>>>>>> 4  MB/10sec
>>>>>>>>
>>>>>>>>
>>>>>>> And  graph where all changes for rx-usecs was done over some time:
>>>>>>> https://ibb.co/nrRfbR
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>> Cant eliminate the problem with settings - memleak is bigger or less
>>>>>> visible with rx-usecs set to low values - but then have 100% cpu load - cant
>>>>>> have rx-usecs set to 16
>>>>>>
>>>>>> Cant find also other host with same cards or that are using i40e driver
>>>>>> for tests with bisecting
>>>>>> So will just replace to mellanox :)
>>>>>>
>>>>>>
>>>>> Also after fresh reboot with i40e
>>>>> startup settings:
>>>>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>>>>> enp3s0f3'
>>>>> for i in $ifc
>>>>>          do
>>>>>          ip link set up dev $i
>>>>>          ethtool -A $i autoneg off rx off tx off
>>>>>          ethtool -G $i rx 2048 tx 2048
>>>>>          ip link set $i txqueuelen 1000
>>>>>          #ethtool -C $i rx-usecs 256
>>>>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 17
>>>>> tx-usecs 125
>>>>>          ethtool -L $i combined 6
>>>>>          #ethtool -N $i rx-flow-hash udp4 sdfn
>>>>>          #ethtool -K $i ntuple on
>>>>>          #ethtool -K $i gro off
>>>>>          #ethtool -K $i tso off
>>>>>          done
>>>>>
>>>>>
>>>>> After issuing:
>>>>>
>>>>>   ethtool -K enp2s0f0 gro on tso on
>>>>>
>>>>> dmesg shows
>>>>> [35764.338259] i40e 0000:02:00.0: PF reset failed, -15
>>>>>
>>>>>
>>>>> and no traffic on the card :)
>>>>>
>>>>>
>>>> Also checked now
>>>> bigger rx ring
>>>>          ethtool -G $i rx 2048 tx 2048
>>>>
>>>>
>>>> Bigger memleag :)
>>>>
>>>>
>>>>
>>> ok need to change cards now to ixgbe .... no reply no help for i40e so
>>> ....
>>>
>>> maybee someone else with i40e will gather more data i have only this host
>>> soo far - will try to install this cards to other hosts after change but
>>> alll this movement will takes about 2 maybee 3 months - nobody from my team
>>> want to but now cards that supports i40e cause of this bug soo this is hard
>>> now to debug - i need to change also all cards now >10G to mellanox that
>>> have no such bug ... sorry :)
>>>
>>>
>> Last tests from my side:)
>> settings
>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>> enp3s0f3'
>> for i in $ifc
>>          do
>>          ip link set up dev $i
>>          ethtool -A $i autoneg off rx off tx off
>>          ethtool -G $i rx 2048 tx 2048
>>          ip link set $i txqueuelen 1000
>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 17 tx-usecs
>> 125
>>          ethtool -L $i combined 6
>>          ethtool -K $i ntuple on
>>          ethtool -K $i gro on
>>          ethtool -K $i tso on
>>          done
>>
>> MEMLEAK 1-2MB/10secs
>> 1  MB/10sec
>> 2  MB/10sec
>> 1  MB/10sec
>> 2  MB/10sec
>> 2  MB/10sec
>> 2  MB/10sec
>> 1  MB/10sec
>> 2  MB/10sec
>> 2  MB/10sec
>> 2  MB/10sec
>> 1  MB/10sec
>> 2  MB/10sec
>> 1  MB/10sec
>> 1  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> 2  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> 5  MB/10sec
>>
>> Change rx-usecs 16 tx usecs 16
>> ifc='enp2s0f0 enp2s0f1 enp2s0f2 enp2s0f3 enp3s0f0 enp3s0f1 enp3s0f2
>> enp3s0f3'
>> for i in $ifc
>>          do
>>          ip link set up dev $i
>>          ethtool -A $i autoneg off rx off tx off
>>          ethtool -G $i rx 2048 tx 2048
>>          ip link set $i txqueuelen 1000
>>          ethtool -C $i adaptive-rx off adaptive-tx off rx-usecs 16 tx-usecs
>> 16
>>          ethtool -L $i combined 6
>>          ethtool -K $i ntuple on
>>          ethtool -K $i gro on
>>          ethtool -K $i tso on
>>          done
>>
>> MEMLEAK: 0-2MB/s with some recycles
>> 0  MB/10sec
>> 0  MB/10sec
>> 0  MB/10sec
>> 0  MB/10sec
>> 0  MB/10sec
>> 0  MB/10sec
>> 1  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> -1  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> 0  MB/10sec
>> 2  MB/10sec
>> -1  MB/10sec
>> 1  MB/10sec
> This data doesn't tell me much of anything and isn't what I asked for.
> I don't see how the interrupt throttling rate would be associated with
> your memory leak other than possibly rate limiting it by rate limiting
> the traffic itself. Is there something that gave you the impression
> that interrupt rate was somehow involved?
more interrupts more leak

>
> When we last talked I had asked if you could do a git bisect to find
> the memory leak and you said you would look into it. The most useful
> way to solve this would be to do a git bisect between your current
> kernel and the 4.11 kernel to find the point at which this started. If
> we can do that then fixing this becomes much simpler as we just have
> to fix the patch that introduced the issue.
>
> Also, I don't know it is you are using to determine that there is a
> memory leak. What tool is it you are using to do the tracking? Is
> there any specific form of traffic that is causing the leak? If you
> can't perform the bisection, any information you could provide that
> would allow me to do it would also be useful.
simple script

mem1=`free -m | grep Mem: | awk '{print $3}'`
sleep 10
mem2=`free -m | grep Mem: | awk '{print $3}'`

num=$((mem2 - mem1))
echo $num " MB/10sec"


There is nothing more that gets mem
there is only routed traffic from interface A to B
nothings takes mem
And memleaks only anchge when i change the rx/tx usecs for card

What You need more ?

imagine this is not my only prblem but many - i just want to help i 
changed cards to i40e based only cause somebody rises a bug - and i want 
to use i40e in feature - dont need them now - but maybee it is good to 
help ppl to solwe some problems now if i can - before i will use this 
cards ?
I try to use i40e before but there was bug covered by bug - and nobody 
from e1000.sf can help me they just reply after year and closing tickets 
with info about no activity but they have info in reported bugs ... 
soooo what is this ? support center ? for me no .
If i want to help -= after a year response will be something like - 
"dont care now" - cause i'v used other hw or sme hacks to repair problem 
that should be sloved by intel

>
> Thanks.
>
> - Alex
>
