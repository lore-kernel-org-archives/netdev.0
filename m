From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 26 Mar 2014 07:31:06 -0400
Message-ID: <5332BA7A.2060003@mojatatu.com>
References: <20140320124021.GA2946@minipsycho.orion> <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com> <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion> <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org> <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org> <5331ED86.7020704@mojatatu.com> <20140325211945.GC15723@casper.infradead.org> <20140326072148.GB2869@minipsycho.orion> <5332B365.6050807@mojatatu.com> <5332B4A0.2070505@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030102000407070004020902"
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:61868 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbaCZLbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 07:31:11 -0400
Received: by mail-oa0-f44.google.com with SMTP id n16so2336195oag.3
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 04:31:11 -0700 (PDT)
In-Reply-To: <5332B4A0.2070505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030102000407070004020902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 03/26/14 07:06, Jamal Hadi Salim wrote:

> If it cant do bonding and the chip is capable of LAGging, it is simply
> the wrong approach. I dont think what has been described so far will
> have a problem doing bonding.

So here's a half a coffee of ascii for yer to just up the game a little.
If cant do this when the chip is capable - then IMO it is the wrong 
interface.

cheers,
jamal

--------------030102000407070004020902
Content-Type: text/plain; charset=us-ascii;
 name="x3"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x3"


   +---------------------+     +---------------------------------------+
   |       br5           |     |            br100                      |
   +-+--+----+---+-+----++     +----+------------+------+------------+-+
     |p0|    |p1 | |eth0|           | bond10     |      |  bond10     |
     ++-+    +-+-+ +----+           +-+---+-+---++      +-+---+--+--+-+
      ^        ^                     |   | |   |         |   |  |  |
      |        |                     |p6 | |p7 |         |p11|  |p8|
      |        |                     +-+-+ +-+-+         +-+-+  +-++
      |        |                       ^     ^             ^      ^
      |        |                       |     |             |      |
      |        |                       |     |             |      |
   +--v--------v-----------------------v-----v-------------v------v----+
   | switch driver (exposes ports and sets bonds/bridges in H/ware)    |
   +------------+--------------------------------+---------------------+
                | Switch control/data interfaces |
                +--------------------------------+
                                | 
                         +-------------+
                         |  Switch HW  |
                         +-------------+


--------------030102000407070004020902--
