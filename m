From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 11:18:20 -0800
Message-ID: <1360955900.19353.22.camel@edumazet-glaptop>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
	 <511E8760.9070703@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:56367 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3BOTSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 14:18:23 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so1575325dak.39
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 11:18:22 -0800 (PST)
In-Reply-To: <511E8760.9070703@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 11:07 -0800, Ben Greear wrote:

> This has been around for a long time, maybe forever.  Last time
> we looked at this it did not appear there was an easy fix, something
> to do with how UDP packets are re-assembled....

This can be fixed the same way we did for IPv4
