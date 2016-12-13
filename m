From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 2/2] net: rfkill: Add rfkill-any LED trigger
Date: Tue, 13 Dec 2016 16:18:32 +0100
Message-ID: <1481642312.20412.3.camel@sipsolutions.net>
References: <20161208073052.12988-1-kernel@kempniu.pl>
         <20161208073052.12988-2-kernel@kempniu.pl>
         (sfid-20161208_083102_765888_8AC6C6B6)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161208073052.12988-2-kernel@kempniu.pl> (sfid-20161208_083102_765888_8AC6C6B6)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-08 at 08:30 +0100, Michał Kępień wrote:
> Add a new "global" (i.e. not per-rfkill device) LED trigger, rfkill-
> any,
> which may be useful on laptops with a single "radio LED" and multiple
> radio transmitters.  The trigger is meant to turn a LED on whenever
> there is at least one radio transmitter active and turn it off
> otherwise.
> 

Also applied, but I moved the discussion of the mutex into the recorded
commit log.

johannes
