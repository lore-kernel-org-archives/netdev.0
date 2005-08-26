From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: ieee80211 patches
Date: Fri, 26 Aug 2005 09:59:00 -0400
Message-ID: <200508260959.01120.flamingice@sourmilk.net>
References: <20050825193112.529d0dc9@griffin.suse.cz> <200508252049.52413.flamingice@sourmilk.net> <200508261104.16134.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jiri Benc <jbenc@suse.cz>,
        NetDev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
        jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200508261104.16134.stefan@loplof.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 August 2005 05:04, Stefan Rompf wrote:
> > - AVS capture header in monitor mode
>
> there has been a discussion about AVS or radiotap header on the ipw list
> that resulted in the inclusion of radiotap definitions in James' latest
> patches for ieee80211. Radiotap requires a libpcap upgrade, but can be
> extended easier. I'd like all linux wireless drivers to move to radiotap
> for statistic data so that userspace has just one format to parse, and a
> new driver would be a perfect target to begin.
>
Sounds like everyone agrees that radiotap is a superior header. I will remove 
AVS support and add radiotap support (if additional code is needed) once 
radiotap code is merged in ieee80211.

Thanks,
-Michael Wu
