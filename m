From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ovs inconsistent lock state
Date: Thu, 13 Feb 2014 21:07:53 +0100
Message-ID: <20140213200753.GE2829@minipsycho.orion>
References: <20140213171307.GC2829@minipsycho.orion>
 <CALnjE+oKrqMVWCrS3kSomxnsSJMFDpFsK8KY+oK1kVTd0Lb8Wg@mail.gmail.com>
 <20140213181257.GD2829@minipsycho.orion>
 <20140213.142654.2111989507538583557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com,
	dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:45117 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaBMUH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:07:57 -0500
Received: by mail-ea0-f182.google.com with SMTP id r15so5374320ead.13
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 12:07:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140213.142654.2111989507538583557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 13, 2014 at 08:26:54PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 13 Feb 2014 19:12:57 +0100
>
>>>> [ 3014.524118]  [<ffffffff815eb585>] ? __dev_queue_xmit+0x5/0x6a0
>  ...
>> I fail to see where bh is disabled. ovs_dp_process_received_packet() is
>> called with rcu_read_lock...
>
>It happens in __dev_queue_xmit(), which does rcu_read_lock_bh().

On tx yes. But how about rx? I don't see it there (rx_handler path).
Maybe I'm missing something.
