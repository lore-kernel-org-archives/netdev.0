From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 17:30:39 +0200
Message-ID: <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
References: <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
	 <20080905113112.GA29926@2ka.mipt.ru>
	 <7e0dd21a0809050544m47deaf0dsf1f31805890ac09@mail.gmail.com>
	 <20080905131618.GB12246@2ka.mipt.ru>
	 <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
	 <20080905133748.GA28656@2ka.mipt.ru>
	 <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
	 <20080905141911.GA16586@2ka.mipt.ru>
	 <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
	 <20080905145902.GA12762@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:52902 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYIEPak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 11:30:40 -0400
Received: by rv-out-0506.google.com with SMTP id k40so495746rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 08:30:40 -0700 (PDT)
In-Reply-To: <20080905145902.GA12762@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,


> Well, udp_sendpage() needs to be extended to only append page when there
> is anough free space there, otherwise push given frame and create next
> packet.
>
Ok, I'll do a patch and let you know result.

>
> I meant you get a pointer by mapping some file in tmpfs (for example)
> and then use some offset variable to store where you put your last data
> (either packet header, or data itself), so that any subsequent write to
> that area (either new packet header or dma data placement) would put
> data just after the previous chunk. Thus after you have put number of
> headers and appropriate data chunks, you could call sendfile() and reset
> offset to the beginning of the mapped area.

If I understand well, there is no link between start of ethernet frame
and packet header ?
App protocol must support packet loss ^^

Thanks,
Johann

-- 
Johann Baudy
johaahn@gmail.com
