From: Rick Jones <rick.jones2@hp.com>
Subject: Re: throughput problems with realtek
Date: Wed, 15 Jan 2014 08:23:16 -0800
Message-ID: <52D6B5F4.1060201@hp.com>
References: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: l.moiseichuk@samsung.com
To: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:43611 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOQXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:23:19 -0500
In-Reply-To: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2014 03:56 AM, Dmitry Kasatkin wrote:
> Hi,
>
> We have several devices with such adapter..
>
> Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411
> PCI Express Gigabit Ethernet Controller (rev 06)
> See output of the lspci -vvv bellow...
>
> And I suddenly investigated throughput issues..
>
> After couple minutes of running 'iperf -c server' transmission speed
> drops substantially...
>
> [  4]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60508
> [  5]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60509
> [  4]  0.0-10.0 sec  1.10 GBytes   949 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60510
> [  5]  0.0-10.0 sec  1.10 GBytes   948 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60511
> [  4]  0.0-10.0 sec   626 MBytes   525 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60512
> [  5]  0.0-10.0 sec  84.4 MBytes  70.5 Mbits/sec
> [  4] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60513
> [  4]  0.0-10.0 sec  87.4 MBytes  73.0 Mbits/sec
> [  5] local 106.122.1.113 port 5001 connected with 106.122.1.121 port 60514
>
>
> But it seems after certain time of inactivity (low load) speed will be
> up again...
>
> It happens almost the same way on desktop machines and also on Samsung
> Series 7 laptop NP770Z5E...
>
> Does anyone have any ideas about it?
>

The card flipping back and forth between 1000 and 100 Mbit/s operation 
perhaps?

rick jones
