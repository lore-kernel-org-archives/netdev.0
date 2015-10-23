From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip, realms: also allow to pass in raw realms
 value
Date: Thu, 22 Oct 2015 23:41:42 -0700
Message-ID: <20151022234142.52790676@xeon-e3>
References: <7b438e1a9424209d64fbb77911a05af37038c74d.1444297002.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34136 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbJWGle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 02:41:34 -0400
Received: by padhk11 with SMTP id hk11so109793274pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 23:41:33 -0700 (PDT)
In-Reply-To: <7b438e1a9424209d64fbb77911a05af37038c74d.1444297002.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Oct 2015 12:22:39 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> If get_rt_realms() fails, try to get a possible raw u32 realms
> value for the u32 RTA_FLOW/FRA_FLOW attribute, as it might be
> useful to directly configure the hex value itself. And only if
> that fails, then bail out.
> 
> The source realm is provided in the upper u16 (mask: 0xffff0000)
> and the destination realm through the lower u16 part (mask:
> 0x0000ffff). This can be useful for tc's bpf realm matcher, but
> also a full hex/mask param can be provided already for matching
> through iptables' --realm cmdline option, for example.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

This looks fine, expected some comments but none received.
Applied.
