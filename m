From: sdrb@onet.eu
Subject: Re: Variable download speed
Date: Wed, 24 Feb 2016 08:48:26 +0100 (CET)
Message-ID: <alpine.LNX.2.20.1602240816180.29937@localhost.localdomain>
References: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain> <CADVnQyngzgLhbo6of1vTq5MH4mk4rSR6_KLWCCXkndK6QYynAw@mail.gmail.com> <alpine.LNX.2.20.1602231455260.29937@localhost.localdomain>
 <CADVnQy=-oh7Ue=Y0vP4ioGrRs7SeJBNq5bkkDVkpogyLpr+9zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo75.poczta.onet.pl ([141.105.16.25]:49988 "EHLO
	smtpo75.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752AbcBXHse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 02:48:34 -0500
In-Reply-To: <CADVnQy=-oh7Ue=Y0vP4ioGrRs7SeJBNq5bkkDVkpogyLpr+9zA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 23 Feb 2016, Neal Cardwell wrote:

> On Tue, Feb 23, 2016 at 8:57 AM,  <sdrb@onet.eu> wrote:
>> I published example pcap file under following link:
>>
>> https://www.dropbox.com/s/v8375ub16seyt1a/test7.pcap?dl=0
>>
>> I hope it is possible to download it without creating dropbox account.
>
> Thanks for the trace. It looks like for the first 0.8 seconds of the
> trace some non-TCP component on the receiving machine (app, CPU, CPU
> power-saving mechanisms, NIC, or NIC driver) is limiting throughput to
> 78Mbit/sec (e.g. the very first window of 10 packets is ACKed at that
> rate). Then the throughput increases to over 200 Mbit/sec. AFAICT it
> doesn't look like the TCP layer is doing anything wrong. I'd look for
> issues with those other components. It might help to report the
> receiver application, receiver CPU type, kernel version, NIC, and NIC
> driver.

Hi,

The receiver application was "wget" using ftp protocol.
Linux kernel is in version 3.4.11-rt19.

Concerning hardware I have not much information about it.
Everything I've got is:

- CPU: ARMv7 Processor rev 1 (v7l)
- NIC: Broadcom PCI: 14e4:aa52
- RAM: 256MB

Unfortunately I've no much info about kernel. Seems like it is some kind 
of realtime version. Can this realtime extension cause such effect of 
increasing throughput?


I've made a graph with window size and throughput from published 
test7.pcap file:

https://www.dropbox.com/s/cwars3oaoax73fh/wget_test_test7pcap_20160224_1.png?dl=0


sdrb
