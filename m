From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH] [NET]: da.s_net not copied but assigned to itself in
 aarp_rcv()
Date: Fri, 2 Mar 2012 13:34:16 -0600
Message-ID: <20120302193416.GA22055@burratino>
References: <4B4F7F4B.8000302@gmail.com>
 <20100114210001.GE20221@ghostprotocols.net>
 <20100115.014943.39860500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, roel.kluin@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Mason Loring Bliss <mason@blisses.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100115.014943.39860500.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller wrote:
>> Em Thu, Jan 14, 2010 at 09:32:11PM +0100, Roel Kluin escreveu:

>>> da.s_net was not copied but assigned to itself.
>>> 
>>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
[...]
> Applied, please always CC: on networking patches.

Thanks.

Without this patch (commit 2a04cd4c7 aka v2.6.33-rc6~29^2~33), Mason
(cc-ed) is not able to use appletalk[1]:

| With Linux 2.6.32 as supplied with Debian Squeeze, Netatalk is unable
| to thrive. Connections made to afpd will open, but attempting to transfer
| files will take a very long time and/or eventually time out.
|
| I've noted this with both Netatalk as supplied with Squeeze and with
| Netatalk 2.2.1 built from the Wheezy source package, which I evidently
| need for AFP 3 support.
|
| Installing Linux 3.2 from backports, with no other changes to the system,
| allows afpd to work correctly.

Ben sent a copy of this patch to try against 2.6.32.y and it worked.
Would it be possible to include this in the 2.6.32.y-longterm tree?

Sincerely,
Jonathan

[1] http://bugs.debian.org/660902
