From: Felix Radensky <felix@allot.com>
Subject: Re: Ethernet bridge performance
Date: Thu, 07 Aug 2003 19:05:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3278CB.5070505@allot.com>
References: <3F3217E7.2080903@allot.com>
 <20030807085930.032b0602.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="Boundary_(ID_5fAUGaz5oHMtphX6UtIryg)"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary_(ID_5fAUGaz5oHMtphX6UtIryg)
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7BIT

It's 2.4.22-pre8. I have to work with 2.4, 2.6 is not an option
at this point.

Felix.

Stephen Hemminger wrote:

>What kernel version?  2.6 should be faster.
>
>On Thu, 07 Aug 2003 12:12:07 +0300
>Felix Radensky <felix@allot.com> wrote:
>
>  
>
>>Hi,
>>
>>I'm evaluating a performance of a dual port ethernet bridge, and the
>>results are a bit disappointing. I would appreciate any hints on improving
>>the results.
>>
>>I'm using a Dual Xeon 2.66 GHz box based on Intel  5701 chipset with  1G
>>of RAM. NICs are e1000 82546 connected to PCIX bus. Kernel is 2.4.22-pre8,
>>e1000  driver version 5.1.13-k1 with NAPI support. NICs' interrupts are 
>>bound
>>to CPU0.
>>
>>The test consists of sending 200 byte UDP packets from 2 ports of Gigabit
>>IXIA traffic generator to 2 bridge ports. The bridge is capable to sustain
>>the rate of ~170000 pps from each IXIA port without drops. I was
>>expecting it to be able to do at least 250000 pps (our own bridge code 
>> based
>>on 2.2.x kernel sustains ~266000 pps on the same hardware).
>>e1000 driver drops 0 packets, all drops occur at higher level.
>>
>>The output of oprofile attached. I'd be happy to provide any info you may
>>need.
>>
>>Thanks in advance for your help.
>>
>>Felix.
>>
>>    
>>
>
>  
>


--Boundary_(ID_5fAUGaz5oHMtphX6UtIryg)
Content-type: text/html; charset=us-ascii
Content-transfer-encoding: 7BIT

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title></title>
</head>
<body>
It's 2.4.22-pre8. I have to work with 2.4, 2.6 is not an option<br>
at this point.<br>
<br>
Felix.<br>
<br>
Stephen Hemminger wrote:<br>
<blockquote type="cite"
 cite="mid20030807085930.032b0602.shemminger@osdl.org">
  <pre wrap="">What kernel version?  2.6 should be faster.

On Thu, 07 Aug 2003 12:12:07 +0300
Felix Radensky <a class="moz-txt-link-rfc2396E" href="mailto:felix@allot.com">&lt;felix@allot.com&gt;</a> wrote:

  </pre>
  <blockquote type="cite">
    <pre wrap="">Hi,

I'm evaluating a performance of a dual port ethernet bridge, and the
results are a bit disappointing. I would appreciate any hints on improving
the results.

I'm using a Dual Xeon 2.66 GHz box based on Intel  5701 chipset with  1G
of RAM. NICs are e1000 82546 connected to PCIX bus. Kernel is 2.4.22-pre8,
e1000  driver version 5.1.13-k1 with NAPI support. NICs' interrupts are 
bound
to CPU0.

The test consists of sending 200 byte UDP packets from 2 ports of Gigabit
IXIA traffic generator to 2 bridge ports. The bridge is capable to sustain
the rate of ~170000 pps from each IXIA port without drops. I was
expecting it to be able to do at least 250000 pps (our own bridge code 
 based
on 2.2.x kernel sustains ~266000 pps on the same hardware).
e1000 driver drops 0 packets, all drops occur at higher level.

The output of oprofile attached. I'd be happy to provide any info you may
need.

Thanks in advance for your help.

Felix.

    </pre>
  </blockquote>
  <pre wrap=""><!---->
  </pre>
</blockquote>
<br>
</body>
</html>

--Boundary_(ID_5fAUGaz5oHMtphX6UtIryg)--
