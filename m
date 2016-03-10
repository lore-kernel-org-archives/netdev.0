From: isdn@linux-pingi.de
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Thu, 10 Mar 2016 17:41:03 +0100
Message-ID: <56E1A39F.1010005@linux-pingi.de>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl> <56E09F4A.8010202@imap.cc>
 <56E15211.7080206@linux-pingi.de> <1457614704.2478.11.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Arnd Bergmann <arnd@arndb.de>,
 linux-doc@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
 Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1457614704.2478.11.camel@tiscali.nl>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Am 10.03.2016 um 13:58 schrieb Paul Bolle:
> Hi Karsten,
> 
> On do, 2016-03-10 at 11:53 +0100, isdn@linux-pingi.de wrote:
>> mISDN with CAPI support works just fine with pppd and pppdcapiplugin
>> and the CAPI works for all mISDN HW.
> 
> In the mainline tree the mISDN and CAPI stacks are effectively separate.
> Do you perhaps refer to a mISDN + Asterisk + chan-capi setup? (That's
> the closest to mISDN with CAPI support that I could find. Did I miss
> something?)

http://listserv.isdn4linux.de/pipermail/isdn4linux/2012-January/005580.html

Since 2012 mISDN has a cAPI20 interface, pure in userspace.
Everything is in the capi20 subdirectory of mISDNuser.
The capi20 support need to be enabled with ./configure.

Has nothing to do with Asterisk, but for FAX it is useing the same DSP
library, spandsp.

Best
Karsten Keil
