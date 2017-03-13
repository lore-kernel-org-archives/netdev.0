From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Enable tx timestamping on loopback and dummy
Date: Mon, 13 Mar 2017 11:35:32 +0100
Message-ID: <20170313103532.GB1875@localhost.localdomain>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
 <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
 <20170312163000.GA1649@localhost.localdomain>
 <20170312203902.GB23127@u480fcf44e5b8574c5490.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ezequiel Lara Gomez <ezegomez@amazon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34902 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbdCMKfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 06:35:38 -0400
Received: by mail-wr0-f180.google.com with SMTP id g10so100603683wrg.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 03:35:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170312203902.GB23127@u480fcf44e5b8574c5490.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 08:39:03PM +0000, Ezequiel Lara Gomez wrote:
> On Sun, Mar 12, 2017 at 05:30:00PM +0100, Richard Cochran wrote:
> > And while you are at it, explain why #1 is needed.
> 
> Certainly - 2 (and 3) come from checkpatch.pl suggestions 
> (I'm mostly following through https://kernelnewbies.org/FirstKernelPatch ), 
> so as suggested I've broken them into a separate patch, being
> styling related only (at least according to that script output).
> 
> The intent behind 1 is helping developing code that does TX timestamping
> - I lost a good chunk of time toying with it until I realised 127.0.0.1
> could not do TX timestamping because lo did not implement it.

IMHO this is not a very convincing reason, but I won't object if
others agree with this change.

In any case, the motivation belongs in the commit message...

Thanks,
Richard
