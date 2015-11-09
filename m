From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [iproute PATCH v2 4/6] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Mon, 9 Nov 2015 21:58:50 +0300
Message-ID: <5640ECEA.8020808@cogentembedded.com>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-5-git-send-email-phil@nwl.cc>
 <5640EB36.306@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33667 "EHLO
	mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbbKIS6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 13:58:54 -0500
Received: by lffz63 with SMTP id z63so35748419lff.0
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 10:58:52 -0800 (PST)
In-Reply-To: <5640EB36.306@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2015 09:51 PM, Sergei Shtylyov wrote:

>> Linux version 3.1 introduced a consistency check for netlink dumps in
>> commit 670dc28 ("netlink: advertise incomplete dumps"). This bites
>
>     The scripts/checkpatch.pl now enforces 12-digit commit ID...

    Sorry, didn't realize it wasn't a kernel patch. :-)

>> iproute2 when flushing more addresses than can fit into a single
>> RTM_GETADDR response. To silence the spurious error message "Dump was
>> interrupted and may be inconsistent.", advise rtnl_dump_filter_l() to
>> not care about NLM_F_DUMP_INTR.
>>
>> Signed-off-by: Phil Sutter <phil@nwl.cc>

[...]

MBR, Sergei
