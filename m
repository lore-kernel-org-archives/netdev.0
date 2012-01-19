From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Thu, 19 Jan 2012 09:58:34 -0800
Message-ID: <4F1859CA.6000407@hp.com>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com> <4F170629.8090307@hp.com> <CAL8zT=jP4Bm=WM0=OLcRgeetzXb0f_ZL0TiDvPAhkbA9UuxpBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:48253 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525Ab2ASR6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 12:58:45 -0500
In-Reply-To: <CAL8zT=jP4Bm=WM0=OLcRgeetzXb0f_ZL0TiDvPAhkbA9UuxpBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2012 12:29 AM, Jean-Michel Hautbois wrote:
> 2012/1/18 Rick Jones<rick.jones2@hp.com>:
>> On 01/18/2012 03:33 AM, Jean-Michel Hautbois wrote:
>>>
>>> Hi all,
>>>
>>> I am currently using netperf/netserver in order to characterize a
>>> benet emulex network device on a machine with 2 Xeon5670.
>>> I am using the latest linux kernel from git (3.2.0+).
>>> I am facing several issues, and I am trying to understand the
>>> following perf stat launched on netserver :
>>>
>>>   Performance counter stats for process id '5043':
>>
>>
>> If you aren't already you may want to gather system-wide data as well - not
>> everything networking is guaranteed to run in the netserver's (or netperf's)
>> context.
>>
>> Might also be good to include the netperf command line driving that
>> netserver.  That will help folks know if the netserver is receiving data
>> (_STREAM), sending data (_MAERTS) or both (_RR) (though perhaps that can be
>> gleaned from the routine names in the profile.
>
> Well, I am only launching netserver without any parameter.

The netperf command line, not netserver :)  The netperf command line 
will tell us what the netserver was asked to and was presumably doing at 
the time the profile was taken.

happy benchmarking,

rick
