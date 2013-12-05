From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net/stable] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Thu, 5 Dec 2013 16:21:52 +0100
Message-ID: <20131205152152.GB2626@minipsycho.orion>
References: <1386255025-23823-1-git-send-email-jiri@resnulli.us>
 <20131205145842.GD23147@redhat.com>
 <20131205150158.GA2626@minipsycho.orion>
 <1386256758.30495.195.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	edumazet@google.com, laine@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:46425 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab3LEPVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 10:21:55 -0500
Received: by mail-ee0-f53.google.com with SMTP id b57so3331526eek.26
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 07:21:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1386256758.30495.195.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 05, 2013 at 04:19:18PM CET, eric.dumazet@gmail.com wrote:
>On Thu, 2013-12-05 at 16:01 +0100, Jiri Pirko wrote:
>
>> I know. But makes more sense to have these getters here, near the
>> struct. I originally moved the definitions near br_handle_frame_finish
>> definition but I think that it is nicer to do it this way...
>
>No, this is really ugly.

Allright. Will send v2 in a jiffy.

>
>
