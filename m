From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: bridge vlan filtering question
Date: Mon, 25 Nov 2013 09:54:42 +0200
Message-ID: <CAF1J0HPkZgiLCY2eiUUWb+t8dJSr2SrUsPtCeHPOxRqU9G6TbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:63344 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab3KYHyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 02:54:43 -0500
Received: by mail-oa0-f53.google.com with SMTP id m1so3972546oag.12
        for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 23:54:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm trying to use brigde vlan filtering and I cannot get any traffic
through the bridge.
After looking at the code I've noticed that br_get_pvid is always
returning VLAN_N_VID because VLAN_TAG_PRESENT is never set in the pvid
field of net_port_vlans.
Am I missing something or is this an actual bug?

-- 
Sincerely yours,
Mike.
