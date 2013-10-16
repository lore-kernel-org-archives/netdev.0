From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SW csum errors
Date: Wed, 16 Oct 2013 08:24:25 -0700
Message-ID: <1381937065.2045.131.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAJoZ4U3yCrGW=5TO5z0FL2HQ+thZVzVfiPOTxTGKBuR=njadOg@mail.gmail.com>
	 <20131014135859.74f38507@nehalam.linuxnetplumber.net>
	 <CAJoZ4U0PNtk2e_x4D3N_fFN32uTVe6Z+FPg7ofG69KjQzsZ7xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Kyle Hubert <khubert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:62414 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab3JPPY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:24:29 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so961188pbc.11
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:24:29 -0700 (PDT)
In-Reply-To: <CAJoZ4U0PNtk2e_x4D3N_fFN32uTVe6Z+FPg7ofG69KjQzsZ7xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 11:10 -0400, Kyle Hubert wrote:

> Thanks, I didn't realize it was as simple as file backed pages being
> changed. Yes, our device does support SG, so we do have zero-copy
> sendfile() support. I'll concoct a simple test to prove this.

You also can use vmsplice()/splice() and touch anonymous memory,
no need to play with a file ;)
