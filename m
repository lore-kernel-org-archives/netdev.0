From: Thomas Graf <tgraf@noironetworks.com>
Subject: Re: [ovs-dev] [RFC: add openvswitch actions using BPF 9/9]
 ofproto-dpif-xlate: generate BPF output action (Hack)
Date: Thu, 5 Feb 2015 15:29:59 +0100
Message-ID: <20150205142959.GE5546@pox.localdomain>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
 <1423090163-19902-10-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.com, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:39142 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757686AbbBEOaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 09:30:03 -0500
Received: by mail-wg0-f42.google.com with SMTP id x13so7938059wgg.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 06:30:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1423090163-19902-10-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 02:49pm, Andy Zhou wrote:
> This is a hack in xlate code to always generate both BPF output
> and the original output action. Since the currnet BPF output 'action'
> simply generate a kenrel log message about the output port number.
> 
> With this patch, Every time datapath output a packet, it also generate
> log about the port number in the kernel log.

This sounds great. Having the possibility the overwrite existing
datapath actions with BPF programs sounds like an excellent first
step towards BPF usage in the datapath.
