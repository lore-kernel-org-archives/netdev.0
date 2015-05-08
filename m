From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multiqueue pktgen and ingress path (Was: [PATCH v5 2/2] pktgen:
 introduce xmit_mode '<start_xmit|netif_receive>')
Date: Fri, 08 May 2015 08:56:09 -0700
Message-ID: <1431100569.22756.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150507143329.8534.49710.stgit@ivy>
	 <20150507143500.8534.4435.stgit@ivy> <554B9293.2070702@plumgrid.com>
	 <554B9CDE.1050703@iogearbox.net> <20150508173900.3fcf78de@redhat.com>
	 <20150508174927.5b1ecdd1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36773 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbEHP4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 11:56:11 -0400
Received: by igbpi8 with SMTP id pi8so24433132igb.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 08:56:11 -0700 (PDT)
In-Reply-To: <20150508174927.5b1ecdd1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-08 at 17:49 +0200, Jesper Dangaard Brouer wrote:

> I'm quite puzzled why a single atomic op could "freeze" my system from
> scaling beyond 24Mpps.

Law of physics, since this cache line has to constantly fly among your
cpus.
