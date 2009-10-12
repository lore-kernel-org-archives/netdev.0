From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Ping Is Broken
Date: Mon, 12 Oct 2009 23:28:56 +0200
Message-ID: <4AD39F98.6050808@gmail.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>	 <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com> <4AD39342.7090209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rob.Townley@gmail.com, netdev@vger.kernel.org,
	Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:59893 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758423AbZJLV3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:29:12 -0400
Received: by mail-bw0-f210.google.com with SMTP id 6so3450992bwz.37
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 14:29:01 -0700 (PDT)
In-Reply-To: <4AD39342.7090209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote, On 10/12/2009 10:36 PM:

> Rob Townley wrote:

...

>> ping -c 2 -B -I  eth0 208.67.222.222
>> PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 eth0: 56(84) bytes of data.
>> From 4.3.2.8 icmp_seq=1 Destination Host Unreachable
>> From 4.3.2.8 icmp_seq=2 Destination Host Unreachable
> 
> In this case ping is doing an SO_BINDTODEVICE to eth0, so the kernel is going
> to force the packets out of it, even if it isn't the "correct" interface.  If
> you ran tcpdump you'd probably see an ARP resolution failure, or an ICMP from
> a gateway.
> 
> This confusion could be cleared-up on the man page.  What did you expect to
> happen in this case?

Actually, ping could do it other way: trying to connect with eth0's
IP address(es). (Then we would need another option for using a dev
like now.)

Jarek P.
