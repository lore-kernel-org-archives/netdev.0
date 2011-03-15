From: Jonathan Morton <chromatix99@gmail.com>
Subject: Re: ECN + pfifo_fast borked? (Was Re: [Bloat] shaper team forming up)
Date: Tue, 15 Mar 2011 19:09:08 +0200
Message-ID: <3D05C1F1-B75E-426B-8267-6DB5323A839D@gmail.com>
References: <87wrk1a4gx.fsf@cruithne.co.teklibre.org> <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com> <1300134277.2649.19.camel@edumazet-laptop> <1300164166.2649.70.camel@edumazet-laptop> <87ipvlosvz.fsf_-_@cruithne.co.teklibre.org> <1300169749.2649.142.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: =?iso-8859-1?Q?Dave_T=E4ht?= <d@taht.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34266 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390Ab1CORJL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 13:09:11 -0400
Received: by wya21 with SMTP id 21so748299wya.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 10:09:10 -0700 (PDT)
In-Reply-To: <1300169749.2649.142.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 15 Mar, 2011, at 8:15 am, Eric Dumazet wrote:

> band 0 : high priority packets (like now)
> band 1 : (old band 1, ECN capable flows)
> band 2 : (old band 1, no ECN flows)
> band 3 : low priority packets (old band 2)

This seems good to me.  It would provide a concrete (if minor) enticement to turn ECN on.

 - Jonathan

