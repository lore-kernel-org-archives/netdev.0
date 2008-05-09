From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 15:43:39 -0700
Message-ID: <4824D39B.6040006@sun.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
 <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc>
 <20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc>
 <4824CBA1.8040703@sun.com> <4824CCF0.5050302@krogh.cc> <4824D1E1.10007@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Jesper Krogh <jesper@krogh.cc>, David Miller <davem@davemloft.net>,
	yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34530 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbYEIWnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:43:14 -0400
In-reply-to: <4824D1E1.10007@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote:

> Jesper Krogh wrote:
>
>> Matheos Worku wrote:
>>
>>> Jesper Krogh wrote:
>>>
>>>> David Miller wrote:
>>>>
>>>>> From: Jesper Krogh <jesper@krogh.cc>
>>>>> Date: Fri, 09 May 2008 20:32:53 +0200
>>>>>
>>>>>> When it works I doesnt seem to be able to get it pass 500MB/s.
>>>>>
>>>>>
>>>>>
>>>>> With this card you really need multiple cpus and multiple threads
>>>>> sending data through the card in order to fill the 10Gb pipe.
>>>>>
>>>>> Single connections will not fill the pipe.
>>>>
>>>>
>>>>
>>>> The server is a Sun X4600 with 8 x dual-core CPU's, setup with 64
>>>> NFS-threads. The other end of the fiber goes into a switch with 
>>>> gigabit
>>>> ports connected to 48 dual-core cpus. The test was done doing a dd 
>>>> on a
>>>> 4.5GB file from the server to /dev/null on the clients.
>>>
>>>
>>>
>>> Are you doing a TX or RX (with respect to the 10G if)?
>>
>>
>>
>> Thats a transmit.. from the NFS server to the clients.
>
Is MSI/MSI-X enabled on the kernel? I have noticed that it was not 
enabled on Gutsy-SPARC?

--Matheos

>
> I have observed TX throughput degradation (and increased CPU 
> utilization)  occurs with increased # of connections, when CPU count > 
> 4 CPUs.  I don't think it is related to the driver (or HW). A while 
> ago I prototyped a driver which drops all UDP TX packets and the 
> throughput degradation (and CPU utilization increase) behavior 
> occurred though the driver was not doing much work.   LSO/TSO seems to 
> help with the situation though. With LSO disabled, I have observed the 
> issue on several 10G nics.
>
> Regards
> Matheos
>
>
>>
>> Jesper
>
>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


