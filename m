From: Cong Wang <cwang@twopensource.com>
Subject: Re: proc net statistics
Date: Mon, 7 Apr 2014 10:06:26 -0700
Message-ID: <CAHA+R7NdyXY4RpqLcrNrUtmWPXNOQmW=ho+QgsGV7DptPOewFg@mail.gmail.com>
References: <1396867174.6220.4.camel@laptop.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Ken O'Brien" <ken@kenobrien.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:48699 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105AbaDGRG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:06:28 -0400
Received: by mail-lb0-f178.google.com with SMTP id s7so5121071lbd.9
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 10:06:27 -0700 (PDT)
In-Reply-To: <1396867174.6220.4.camel@laptop.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 3:39 AM, Ken O'Brien <ken@kenobrien.org> wrote:
> Hi,
>
> I was under the impression that statistics reported
> in /proc/{$pid}/net/dev were specific to that process, but the values
> appear to be globals, i.e., identical for all processes.
>
> Is this a bug?

That is per network-namespace statistics, so it is
not a bug.
