From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Tue, 09 Apr 2013 06:44:35 -0700
Message-ID: <1365515075.3887.122.camel@edumazet-glaptop>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
	 <1365175702.3405.2.camel@edumazet-glaptop>
	 <1365175872.3405.3.camel@edumazet-glaptop>
	 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
	 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
	 <1365436285.3887.16.camel@edumazet-glaptop>
	 <20130409075532.GA20363@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39594 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab3DINoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:44:39 -0400
Received: by mail-pd0-f182.google.com with SMTP id 3so3779477pdj.41
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 06:44:39 -0700 (PDT)
In-Reply-To: <20130409075532.GA20363@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-09 at 09:55 +0200, Erik Hugne wrote:

> I haven't found any issues with the GRO support itself. It's only on
> the system with Emulex NIC's that i have problems.
> Unfortunately, I'm stuck to kernel 3.0.61 on these machines, newer kernels
> won't boot due to an unresolved driver issue with the hw raid controller :/

I suggested you try GRE tunnels on emulex NIC, to make sure the problem
is not coming from your changes. Nevermind ...
