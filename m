From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 15:02:04 -0400
Message-ID: <525EE2AC.50002@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com>	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>	 <525ED1AE.7050101@mojatatu.com> <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com> <525EE00A.20209@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:52925 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933954Ab3JPTJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 15:09:09 -0400
Received: by mail-yh0-f42.google.com with SMTP id z6so288574yhz.1
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 12:09:08 -0700 (PDT)
In-Reply-To: <525EE00A.20209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/13 14:50, Vlad Yasevich wrote:

> Right.  ip link show is dumb.  It asks for info from all devices and
> then filters based on the device you asked for, but the filtering
> is done in iproute instead of the kernel.
>

That maybe small flaw in iproute2 - but there's no issue in the kernel.
You can send an ifi and specify the proper ifindex of choice.
But you cant do the same with bridge.
Thats what i was whining to Stephen about. I get every
bridge port with no exception and there's no way to specify one
(the ifi ifindex is never used).
Think 20K bridge ports - each giving me 1K of data ...
scalability problem

cheers,
jamal
