From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Subject: Re: [PATCH] Enable tx timestamping on loopback and dummy
Date: Sun, 12 Mar 2017 20:39:03 +0000
Message-ID: <20170312203902.GB23127@u480fcf44e5b8574c5490.ant.amazon.com>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
 <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
 <20170312163000.GA1649@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:26242 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934692AbdCLUjE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 16:39:04 -0400
Content-Disposition: inline
In-Reply-To: <20170312163000.GA1649@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 12, 2017 at 05:30:00PM +0100, Richard Cochran wrote:
> On Sun, Mar 12, 2017 at 12:17:30AM +0100, Oliver Hartkopp wrote:
> > in fact you're doing three different things here:
> > 
> > 1. introduce tx timestamping
> > 2. silently change an include: <asm/io.h> -> <linux/io.h>
> > 3. fix some whitespace and empty line issues
> > 
> > You'd better provide one patch for 1 & 2 and explain why 2 is needed.
> 
> And while you are at it, explain why #1 is needed.

Certainly - 2 (and 3) come from checkpatch.pl suggestions 
(I'm mostly following through https://kernelnewbies.org/FirstKernelPatch ), 
so as suggested I've broken them into a separate patch, being
styling related only (at least according to that script output).

The intent behind 1 is helping developing code that does TX timestamping
- I lost a good chunk of time toying with it until I realised 127.0.0.1
could not do TX timestamping because lo did not implement it.

>
> 
> Thanks,
> Richard
> 
Amazon Data Services Ireland Limited registered office: One Burlington Plaza, Burlington Road, Dublin 4, Ireland. Registered in Ireland. Registration number 390566.
