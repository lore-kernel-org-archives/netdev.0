From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 03/10] vxlan: move IGMP join/leave to work queue
Date: Thu, 6 Jun 2013 08:49:42 +0800
Message-ID: <CAM_iQpWbmdpgKX7rb=Dr6ZyCbO+bNfr20QSJdf1PRKJDAZ47eQ@mail.gmail.com>
References: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
	<1370406254-6341-3-git-send-email-stephen@networkplumber.org>
	<kommuo$ma8$1@ger.gmane.org>
	<20130605084203.77dad08a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:49155 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab3FFAtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 20:49:42 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so3705205obc.27
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 17:49:42 -0700 (PDT)
In-Reply-To: <20130605084203.77dad08a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 11:42 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> What was the order of events (ie. what did you do to make it happen)?

1. generate some traffic via vxlan0 with ping
2. at the same time delete vxlan0

this is 100% reproducible.
