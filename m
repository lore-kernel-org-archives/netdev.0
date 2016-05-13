From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: set mac_header correctly in GPE mode
Date: Fri, 13 May 2016 13:21:45 +0300
Message-ID: <20160513132145.65764ae2@halley>
References: <2f5ecda4984940c2c6820cbbed18555d5023e2ed.1463129287.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38223 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcEMKVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 06:21:49 -0400
Received: by mail-wm0-f41.google.com with SMTP id g17so22199573wme.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 03:21:49 -0700 (PDT)
In-Reply-To: <2f5ecda4984940c2c6820cbbed18555d5023e2ed.1463129287.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 13 May 2016 10:48:42 +0200 Jiri Benc <jbenc@redhat.com> wrote:
> For VXLAN-GPE, the interface is ARPHRD_NONE, thus we need to reset
> mac_header after pulling the outer header.
> 
> v2: Put the code to the existing conditional block as suggested by
>     Shmulik Ladkani.
> 
> Fixes: e1e5314de08b ("vxlan: implement GPE")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
