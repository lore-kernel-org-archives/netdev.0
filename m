From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] ip_tunnel: create percpu gro_cell
Date: Fri, 09 Jan 2015 17:02:39 -0800
Message-ID: <1420851759.5947.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420828933-844290-1-git-send-email-kafai@fb.com>
	 <1420844264.5947.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150109231703.GF3842288@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: Martin Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33871 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbbAJBCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 20:02:42 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so4389077igi.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 17:02:41 -0800 (PST)
In-Reply-To: <20150109231703.GF3842288@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-09 at 15:17 -0800, Martin Lau wrote:
> Is the spin_lock() still needed?

Think about cpu hotplug, we can have interesting things here.

Basically no cost at all once mem is percpu.
