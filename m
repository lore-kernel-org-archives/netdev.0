From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH][net-next][v2] bridge: allow the maximum mtu to 64k
Date: Wed, 24 Feb 2016 13:44:56 -0800
Message-ID: <20160224134456.3ea94f0a@xeon-e3>
References: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35306 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcBXVos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:44:48 -0500
Received: by mail-pf0-f181.google.com with SMTP id c10so20644020pfc.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 13:44:47 -0800 (PST)
In-Reply-To: <1456189256-7811-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2016 09:00:56 +0800
roy.qing.li@gmail.com wrote:

> This is especially annoying for the virtualization case because the
> KVM's tap driver will by default adopt the bridge's MTU on startup
> making it impossible (without the workaround) to use a large MTU on the
> guest VMs.
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1399064

This use case looks like KVM misusing bridge MTU. I.e it should set TAP
MTU to what it wants then enslave it, not vice versa.
