From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 15:55:14 +0200
Message-ID: <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
References: <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
	 <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
	 <20080905071754.GA25998@2ka.mipt.ru>
	 <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
	 <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
	 <20080905113112.GA29926@2ka.mipt.ru>
	 <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
	 <20080905131618.GB12246@2ka.mipt.ru>
	 <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
	 <20080905133748.GA28656@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:52579 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbYIENzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 09:55:15 -0400
Received: by rv-out-0506.google.com with SMTP id k40so462443rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 06:55:14 -0700 (PDT)
In-Reply-To: <20080905133748.GA28656@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> That's a bug. Likely no one sends file content via udp, so it was not
> detected...

Ok, I'll will run a FTRACE of this issue on monday;

>> I will try to investigate it but for my app sendfile() is not
>> conceivable. Only vmsplice could, but too slow.
>
> Well, you can mmap empty file into the RAM, lock it there, DMA data from
> the sensor to the mmapped area, add headers (just in the mapped area)
> and then sendfile that file.. Single syscall, zero-copy, standard
> interfaces :)
>

OK but it seems that there is no way to control packet format.
(beginning of packet and size of packet).
Each packet must start with a specific header (on my app). This is a
kind of streaming.

Thanks,
Johann





-- 
Johann Baudy
johaahn@gmail.com
