From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: Should linux send netlink message as it is deleting that routing
 entry?
Date: Wed, 16 Apr 2014 18:50:46 +0800
Message-ID: <534E6086.9020103@gmail.com>
References: <534654FE.3040804@gmail.com>	<5347B2C4.6040103@gmail.com> <20140411113042.4328c39c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	ebiederm@xmission.com, ja@ssi.bg,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	"Zadoyan, Grant" <Grant.Zadoyan@windriver.com>,
	eric.dumazet@gmail.com, socketcan@hartkopp.net,
	hannes@stressinduktion.org, cwang@twopensource.com,
	zhuyj <zyjzyj2000@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:52018 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386AbaDPKuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 06:50:54 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so11900553qcx.27
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 03:50:53 -0700 (PDT)
In-Reply-To: <20140411113042.4328c39c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2014 02:30 AM, Stephen Hemminger wrote:
> On Fri, 11 Apr 2014 17:15:48 +0800
> zhuyj <zyjzyj2000@gmail.com> wrote:
>
>>> With ubuntu 12.04, I run the following to reproduce this defect.
>>>
>>> 1) Configure an interface
>>> ifconfig eth1 150.0.0.1/24 up
>>>
>>> 2) Add routing entry via that interface address
>>> route add -net 200.0.0.0/24 gw 150.0.0.1
>>>
>>> 3) Change the ip address on that interface as shown below.
>>> ifconfig eth1 151.0.0.1/24 up
>>>
>>> 4) Check netlink messages with "ip monitor all". There is no route
>>> delete netlink message.
>>>
> With IPv4 there are several cases where there is a non-notified
> implicit route withdrawal. This is not something that can be fixed.
> There are two issues:
>   1. with large backbone size route tables (ie 1M routes), the number
>      of notification messages becomes a bottleneck and would be unreliable
>   2. the existing routing daemons (quagga, bird, etc) all understand/expect
>      the existing semantics
>
Hi,

Thanks a lot.

Best Regards!
Zhu Yanjun
