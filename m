From: Cong Wang <cwang@twopensource.com>
Subject: Re: proc net statistics
Date: Mon, 7 Apr 2014 10:19:35 -0700
Message-ID: <CAHA+R7O+1gP4U-YiBHdJeEO1hvH41NcGoRZ5iW_W25CBaXWbnA@mail.gmail.com>
References: <1396867174.6220.4.camel@laptop.site>
	<CAHA+R7NdyXY4RpqLcrNrUtmWPXNOQmW=ho+QgsGV7DptPOewFg@mail.gmail.com>
	<1396890659.3063.4.camel@mjolnir.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ken O'Brien" <ken@kenobrien.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:38009 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbaDGRTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:19:37 -0400
Received: by mail-lb0-f179.google.com with SMTP id p9so5145029lbv.10
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 10:19:36 -0700 (PDT)
In-Reply-To: <1396890659.3063.4.camel@mjolnir.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 10:10 AM, Ken O'Brien <ken@kenobrien.org> wrote:
>
> Ok, so then, is there a way to read per process network statistics in the proc filesystem?
>

AFAIK, we only have per-socket and per-netdev statistics, there is no
per-process one, you probably want to try cgroup, or put these processes
into a namespace.
