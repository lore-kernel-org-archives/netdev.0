From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Problem with 2.4.24 e1000 and keepalived
Date: Thu, 8 Jan 2004 06:20:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108052000.GA8829@alpha.home.local>
References: <20040107200556.0d553c40.skraw@ithnet.com> <20040107210255.GA545@alpha.home.local> <3FFCC430.4060804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <willy@w.ods.org>,
        Stephan von Krawczynski <skraw@ithnet.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3FFCC430.4060804@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Ben,

On Wed, Jan 07, 2004 at 06:45:04PM -0800, Ben Greear wrote:
 
> You have to bring the interface 'UP' before it will detect link,
> with something like:  ifconfig eth2 up

Don't you mean "after" instead of "before" here ? Because the case where
it doesn't work is when everything is set up while the cable is unplugged,
but conversely, if the system goes up with the cable plugged, setting the
interface UP detects the link as UP and works. I believe that the problem
is related to setting the interface UP with nothing plugged into it.

Cheers,
Willy
