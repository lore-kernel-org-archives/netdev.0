From: Stefan Rompf <stefan@loplof.de>
Subject: Re: ieee80211 patches
Date: Fri, 26 Aug 2005 11:04:15 +0200
Message-ID: <200508261104.16134.stefan@loplof.de>
References: <20050825193112.529d0dc9@griffin.suse.cz> <200508252049.52413.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jiri Benc <jbenc@suse.cz>,
        NetDev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
        jbohac@suse.cz, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200508252049.52413.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Am Freitag 26 August 2005 02:49 schrieb Michael Wu:

> I hope to submit the adm8211 driver for review soon, but there's a bunch of
> code in the driver which probably belong in the ieee80211 code:
[...]
> - AVS capture header in monitor mode

there has been a discussion about AVS or radiotap header on the ipw list that 
resulted in the inclusion of radiotap definitions in James' latest patches 
for ieee80211. Radiotap requires a libpcap upgrade, but can be extended 
easier. I'd like all linux wireless drivers to move to radiotap for statistic 
data so that userspace has just one format to parse, and a new driver would 
be a perfect target to begin.

Stefan
