From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Wed, 5 Jan 2011 16:45:37 +0100
Message-ID: <AANLkTi=0gRFeboXcEji_+w-7sNadwLvqAOarGShwtyRE@mail.gmail.com>
References: <20110101090212.7149010d@osprey.hogchain.net>
	<AANLkTinizyGFhzTgTMQ=ojL4v+htqvRM9c62dgHUss3f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org, jussuf@linux.ee, chris.snook@gmail.com,
	Xiong.Huang@atheros.com
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51236 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab1AEPpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 10:45:42 -0500
Received: by gwj20 with SMTP id 20so6951695gwj.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 07:45:41 -0800 (PST)
In-Reply-To: <AANLkTinizyGFhzTgTMQ=ojL4v+htqvRM9c62dgHUss3f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 5, 2011 at 4:42 PM, Luca Tettamanti <kronos.it@gmail.com> wrote:
> So here you're using pointers to freed memory.
> In order to preserve the stats you'd have to copy the structure.

Doh. I still haven't recovered from all the partying ;-)
Sorry for the noise...

L
