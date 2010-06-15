From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ftp on udp and tcp .
Date: Tue, 15 Jun 2010 12:50:14 +0100
Message-ID: <1276602615.14011.464.camel@localhost>
References: <AANLkTimz7A03_UwOcjgrixqGH9MW8i1dAH6ULfR-sS5z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <AANLkTimz7A03_UwOcjgrixqGH9MW8i1dAH6ULfR-sS5z@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-06-15 at 12:50 +0530, ratheesh k wrote:
> Hi ,
> 
>        what is real advantage of UDP over TCP / TCP over UDP .  If i
> put the question in a different way - if run ftp application on UDP
> and TCP , what is the real difference / advantage  ??

TCP handles segmentation and bandwidth/congestion management.  It
recovers from packet loss and reordering.  Recent implementations are
also quite resilient to address spoofing.  The downsides are higher
latency (potentially very high when recovering from packet loss), higher
setup cost (3-way handshake), and lack of multicast support.

UDP does none of that.  It gives you flexibility and control, but the
downside is you have to handle all of those problems yourself.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

