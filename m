From: Felix Radensky <felix@allot.com>
Subject: Re: Ethernet bridge performance
Date: Sun, 10 Aug 2003 10:32:43 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F35F51B.7080301@allot.com>
References: <3F3217E7.2080903@allot.com> <3F3284EA.5050406@candelatech.com>
 <3F328A0F.3040005@allot.com> <16178.41976.3643.584516@robur.slu.se>
 <1060284094.1024.36.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="Boundary_(ID_UirtBd6b6YWS5joOM6NHtg)"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary_(ID_UirtBd6b6YWS5joOM6NHtg)
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7BIT

Hi, Jamal

I guess you were not reading my first posting
very carefully :)

2.4.22 has NAPI capable e1000 driver and I've
compiled the driver with NAPI support.

So running non-NAPI driver is not my problem.

Felix.

jamal wrote:

>Actually seems his biggest problem is he is not running
>the NAPI driver
>
>cheers,
>jamal
>
>On Thu, 2003-08-07 at 15:09, Robert Olsson wrote:
>  
>
>>Felix Radensky writes:
>> > Thanks for your help, Ben. What is skb-recycle patch
>> > and where can I find it ?
>> 
>> It's experimental and not updated for almost a year and current 
>> implementation does not add anything to SMP. Got some idea how
>> to improve this... but try to keep to slab as long as possible 
>> it has been improved.
>>
>> Routing/bridging on SMP has affinty problem. If you are passing
>> skb's say from eth0 to eth1 and they are bound on different CPU's
>> you get cache boucing since the TX-interrupts come on another CPU.
>>
>> In a recent test with pktgen:
>> 300 kpps with TX interrupts on same CPU as sender.
>> 198 kpps with TX intr on different CPU as sender.
>>
>> Recycling tries to address this but current implementation fails
>> as said.
>>
>> But you are probably hit by something else... Check were the drops 
>> happens qdisc?. NIC ring RX/TX size, Number of interrupts. ksoftird 
>> priority, link HW_FLOW control, checksumming, affinity etc. 
>>
>> 
>> Cheers.
>>						--ro
>>
>>
>>    
>>
>
>  
>


--Boundary_(ID_UirtBd6b6YWS5joOM6NHtg)
Content-type: text/html; charset=us-ascii
Content-transfer-encoding: 7BIT

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title></title>
</head>
<body>
Hi, Jamal<br>
<br>
I guess you were not reading my first posting <br>
very carefully :)<br>
<br>
2.4.22 has NAPI capable e1000 driver and I've<br>
compiled the driver with NAPI support. <br>
<br>
So running non-NAPI driver is not my problem.<br>
<br>
Felix.<br>
<br>
jamal wrote:<br>
<blockquote type="cite"
 cite="mid1060284094.1024.36.camel@jzny.localdomain">
  <pre wrap="">Actually seems his biggest problem is he is not running
the NAPI driver

cheers,
jamal

On Thu, 2003-08-07 at 15:09, Robert Olsson wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">Felix Radensky writes:
 &gt; Thanks for your help, Ben. What is skb-recycle patch
 &gt; and where can I find it ?
 
 It's experimental and not updated for almost a year and current 
 implementation does not add anything to SMP. Got some idea how
 to improve this... but try to keep to slab as long as possible 
 it has been improved.

 Routing/bridging on SMP has affinty problem. If you are passing
 skb's say from eth0 to eth1 and they are bound on different CPU's
 you get cache boucing since the TX-interrupts come on another CPU.

 In a recent test with pktgen:
 300 kpps with TX interrupts on same CPU as sender.
 198 kpps with TX intr on different CPU as sender.

 Recycling tries to address this but current implementation fails
 as said.

 But you are probably hit by something else... Check were the drops 
 happens qdisc?. NIC ring RX/TX size, Number of interrupts. ksoftird 
 priority, link HW_FLOW control, checksumming, affinity etc. 

 
 Cheers.
						--ro


    </pre>
  </blockquote>
  <pre wrap=""><!---->
  </pre>
</blockquote>
<br>
</body>
</html>

--Boundary_(ID_UirtBd6b6YWS5joOM6NHtg)--
