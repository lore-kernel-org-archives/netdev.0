From: Jim Wylder <jwylder1@motorola.com>
Subject: Re: [PATCH] usbnet: ignore get interface retval of -EINPROGRESS
Date: Mon, 5 Sep 2011 11:36:54 -0500
Message-ID: <CAPopfEXgR68y=Hsmx4q4Up7NqhLmbZ03N1=50eKKaB8EJ0aHfQ@mail.gmail.com>
References: <CAPopfEUUaEChuh1mdZnHHT_9uRfsQmwMu7=gjnYr=AmFWik2HA@mail.gmail.com>
	<201109031837.48444.oliver@neukum.org>
	<CAPopfEWi0v9VXeDYcBfEgnWYxg7WcTTj3GBc6USzwcN+aGrKOQ@mail.gmail.com>
	<201109041216.12127.oliver@neukum.org>
	<CAPopfEXz+HPdwWh_GQ2WzMnHh5DuXTse78NAU=-iN15wv-0C5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:60523 "EHLO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1IEQg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 12:36:58 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.22.94.168])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p85Gbn4S014305
	for <netdev@vger.kernel.org>; Mon, 5 Sep 2011 12:37:49 -0400 (EDT)
Received: from mail-ww0-f46.google.com (mail-ww0-f46.google.com [74.125.82.46])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p85Gbm4x014299
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 5 Sep 2011 12:37:49 -0400 (EDT)
Received: by wwg7 with SMTP id 7so4933391wwg.3
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2011 09:36:54 -0700 (PDT)
In-Reply-To: <CAPopfEXz+HPdwWh_GQ2WzMnHh5DuXTse78NAU=-iN15wv-0C5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver,

I have a couple of questions about this:

- Does the macro as implemented properly communicate the intent as you
requested?

- You made a comment about this being useful outside of usbnet.  The
only appropriate place that I could identify for this would be all the
way up in usb.h.  Do you think something at that level is more
appropriate?

Jim
