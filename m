From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Thu, 09 Oct 2014 15:34:54 +0400
Message-ID: <543672DE.80202@cogentembedded.com>
References: <1412803407-10621-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Graf <agraf@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36697 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755955AbaJILe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 07:34:58 -0400
Received: by mail-la0-f41.google.com with SMTP id pn19so978351lab.14
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 04:34:56 -0700 (PDT)
In-Reply-To: <1412803407-10621-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/9/2014 1:23 AM, Alexander Graf wrote:

> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac

   Please also specify that commit's summary line in parens.

> address to the VF on reset rather than a random one.

> However, that behavioral change also requires igbvf driver changes
> which can be hard especially when we want to talk to proprietary
> guest OSs.

> Looking at the code previous to the commit in Linux that made igbvf
> work with empty mac addresses (8d56b6d), we can see that on reset

    And that one's

> failure the driver will try to generate a new mac address with both
> the old and the new code.

> Furthermore, ixgbe does send reset failure when it detects an empty
> mac address (35055928c).

    And that one's too.

> So I think it's safe to make igb behave the same. With this patch I
> can successfully run a Windows 8.1 guest with an empty mac address
> and an assigned igbvf device that has no mac address set by the host.

> If anyone is aware of a guest driver that chokes on NACK returns of
> VF RESET commands, please speak up.

> Signed-off-by: Alexander Graf <agraf@suse.de>

WBR, Sergei
