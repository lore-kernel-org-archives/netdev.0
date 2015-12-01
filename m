From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 16:25:40 -0800
Message-ID: <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com> <20151129.222138.1582847465760563254.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44565 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbbLAA0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 19:26:02 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id C48362066F
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 00:26:01 +0000 (UTC)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 84DF820664
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 00:26:00 +0000 (UTC)
Received: by qkfo3 with SMTP id o3so66245433qkf.1
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 16:25:59 -0800 (PST)
In-Reply-To: <20151129.222138.1582847465760563254.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 29, 2015 at 7:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 23 Nov 2015 13:53:44 -0800
>
>> The bad effect of this model is that it is encourages HW vendors to
>> continue implement HW protocol specific support for encapsulations, we
>> get so much more benefit if they implement protocol generic
>> mechanisms.
>
> +1

Regardless of what happens in the future, I think the main question is
how this relates to the code that is currently present in the tree. We
already have NDOs for VXLAN offloading, which is about as protocol
specific as you can get. In my mind, this series is strictly an
improvement to what is already there - it pulls all hardware
offloading code out of the various protocol implementations and VXLAN
out of the driver interface. That seems like a pretty nice cleanup to
me.
