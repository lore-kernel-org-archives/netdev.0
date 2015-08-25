From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] vxlan: fix multiple inclusion of vxlan.h
Date: Tue, 25 Aug 2015 11:45:34 -0700
Message-ID: <CAHA+R7MDHpmsQ1vowC3CQ5Fsx8gn7JTAJPV__tS2CZWQ8LYmXA@mail.gmail.com>
References: <27e0c4c1aec49f461ba96fac8c40f69b46ef06dd.1440520548.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Mark Rustad <mark.d.rustad@intel.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34751 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbHYSpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:45:36 -0400
Received: by lbbtg9 with SMTP id tg9so106207230lbb.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 11:45:34 -0700 (PDT)
In-Reply-To: <27e0c4c1aec49f461ba96fac8c40f69b46ef06dd.1440520548.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 9:36 AM, Jiri Benc <jbenc@redhat.com> wrote:
> The vxlan_get_sk_family inline function was added after the last #endif,
> making multiple inclusion of net/vxlan.h fail. Move it to the proper place.
>

Or move it even further into #if IS_ENABLED(CONFIG_VXLAN) ?
