From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: bridge vlan filtering question
Date: Mon, 25 Nov 2013 13:19:40 -0500
Message-ID: <529394BC.5060805@gmail.com>
References: <CAF1J0HPkZgiLCY2eiUUWb+t8dJSr2SrUsPtCeHPOxRqU9G6TbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:56262 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860Ab3KYSTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 13:19:42 -0500
Received: by mail-yh0-f53.google.com with SMTP id b20so3056393yha.26
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 10:19:42 -0800 (PST)
In-Reply-To: <CAF1J0HPkZgiLCY2eiUUWb+t8dJSr2SrUsPtCeHPOxRqU9G6TbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2013 02:54 AM, Mike Rapoport wrote:
> Hi all,
> 
> I'm trying to use brigde vlan filtering and I cannot get any traffic
> through the bridge.
> After looking at the code I've noticed that br_get_pvid is always
> returning VLAN_N_VID because VLAN_TAG_PRESENT is never set in the pvid
> field of net_port_vlans.
> Am I missing something or is this an actual bug?
> 

It's a bug.  It's been fixed upstream and has been queued to stable.

commit d1c6c708c4da9d104e0b7c116654cb449bff9b5f
Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date:   Wed Oct 16 17:07:15 2013 +0900

    bridge: Fix the way the PVID is referenced


-vlad
