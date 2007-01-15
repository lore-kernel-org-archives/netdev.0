From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Two Dual Core processors and NICS (not handling interrupts on one CPU/assigning a Two Dual Core processors and NICS (not handling interrupts on one CPU / assigning a CPU to a NIC)
Date: Mon, 15 Jan 2007 11:58:12 +0200
Message-ID: <7e63f56c0701150158r4e9b95ar996a33a5294cfa56@mail.gmail.com>
References: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:61931 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166AbXAOJ6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 04:58:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1304341uga
        for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 01:58:12 -0800 (PST)
To: "Mark Ryden" <markryde@gmail.com>
In-Reply-To: <dac45060701150115y5308f7b5ka44f2ea4ae304d4b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mark,

On 1/15/07, Mark Ryden <markryde@gmail.com> wrote:
> I have a machine with 2 dual core CPUs. This machine runs Fedora Core 6.
> I have two Intel e1000 GigaBit network cards on this machine; I use bonding so
> that the machine assigns the same IP address to both NICs ;

> cat /proc/interrupts shops something like this:
>                                 CPU0       CPU1         CPU2         CPU3
>  50:    3359337          0          0          0         PCI-MSI  eth0
>  58:         49    3396136          0          0         PCI-MSI  eth1
>
>  CPU0 and CPU1 are of the first CPU as far as I understand ; so
>  this means as far as I understand that the second CPU (which has CPU3
> and CPU4) does not handle
>  interrupts of the arrived packets; Can I somehow change it so the second
>  CPU will also handle network interrupts of receiving packets on the nic ?
>
> Can I assign one CPU to  eth0 and the second CPU to eth1  ?

How it will help you?
Y can set smp-affinity mask for each irq in /proc/<irq-number>/
google for 'linux smp-affinity".

The subject in more details is discussed in:
http://linux-net.osdl.org/index.php/TODO#TCP
and thread
http://marc.theaimsgroup.com/?t=116695290600001&r=1&w=2, read from
bottom.


-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
A powerful open-source HTTP/S, FTP/S traffic
generating, loading and testing tool.
