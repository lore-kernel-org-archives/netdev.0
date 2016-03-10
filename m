From: isdn@linux-pingi.de
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Thu, 10 Mar 2016 11:53:05 +0100
Message-ID: <56E15211.7080206@linux-pingi.de>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <56D7F62E.6050502@linux-pingi.de> <1659125.tHp8H942OG@wuerfel>
 <1457108303.2651.112.camel@tiscali.nl> <56DADA57.9010200@imap.cc>
 <1457340486.2737.19.camel@tiscali.nl> <56E09F4A.8010202@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-doc@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Tilman Schmidt <tilman@imap.cc>, Paul Bolle <pebolle@tiscali.nl>,
 Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <56E09F4A.8010202@imap.cc>
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

Am 09.03.2016 um 23:10 schrieb Tilman Schmidt:
> Am 07.03.2016 um 09:48 schrieb Paul Bolle:
>> On za, 2016-03-05 at 14:08 +0100, Tilman Schmidt wrote:
>>> As a consequence, owners of HiSAX type adapters are in fact stuck with
>>> the old hisax driver if they want to continue using i4l userspace
>>> tools.
>>
>> Do you know whether or not mISDN tools offer functionality comparable to
>> i4l tools?
> 
> AFAICS they don't. mISDN seems very much geared towards voice use, for
> example with Asterisk. The entire topic of ISDN data connections appears
> to be missing. I don't see how someone currently using i4l for Internet
> dial-in (either client or server side) could migrate to mISDN.
> 

Not true.
mISDN with CAPI support works just fine with pppd and pppdcapiplugin and
the CAPI works for all mISDN HW.

Following I4L services are not supported:

- RAW IP dialin/dialout
- termnal connections via X75 (e.g. dialin via minicom on a remote machine).
- isdndivert

RAW IP was very popular in the nineties because of easy to setup and low
protocol overhead, but very insecure, since only authorization was done
by the phone numbers. This was not a such big issue in the nineties,
since it was hard to get a public line with the allowance to send any
numbers.
Today this is no problem to get the allowance (if you can get a new ISDN
line at all - which is more a problem today).
Terminal connection where only used seldom, more as last resort or for
debuging.
isdndivert was used to manage call redirections, it could be easely
replaced by an mISDN or CAPI application, but here were not so much
requests for it. Since Telekom offers callredirection in their Web
customer center here is no much need anyways.


Karsten
