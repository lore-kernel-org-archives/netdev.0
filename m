From: Mark Smith <markzzzsmith@ozemail.com.au>
Subject: [PATCH] 802.3x / ETHTOOL Pause frame support for natsemi.c (netgear
	fa311/fa312 + ns83816)
Date: 31 Jan 2003 00:25:19 +1030
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1043934941.848.21.camel@dupy>
References: <1043583669.1774.22.camel@dupy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: thockin@hockin.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Smith <markzzzsmith@ozemail.com.au>
In-Reply-To: <1043583669.1774.22.camel@dupy>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Tim, All,

Isn't it always the way ? Downloaded the new version of the natsemi
NS83815.pdf file (dated Sep 2002), and the message about the 83815 (used
on the Netgear Fa311 / Fa312 cards) not supporting ethernet pause frames
has disappeared.

Looks like a bug in the old doco rather than the hardware.

Here is the updated patch, with the check for the NS83816 chip removed.

It applies to natsemi.c version 1.0.17, which is contained in both
versions 2.4.20 and 2.5.56 of the linux kernel.

I'm hoping other people can help me test it, I'd appreciate bug reports,
suggestions and other constructive criticism.

I've put the patch here 

http://www.nosense.org/natsemi.c.ethpause.1.1.diff

just in case attaching it to my last email was a bit rude (I didn't
think a 5 KB email was too big, my appologies if it was).


Thanks,
Mark.


On Sun, 2003-01-26 at 22:51, Mark Smith wrote:
> Hi Tim, *
> 
> I've put together the following patch to enable 802.3x ethernet pause
> frame support, including the ethtool pause options, on the natsemi 83816
> based network cards.
> 
> I've tested it on my 83815 based Netgear FA312 card, which does have all
> the required registers, but according to page 69 of the NS83815.pdf
> document, the pause feature is not supported. I added the check for
> 83816 chips just as the final step before posting it.
> 
> I haven't done any kernel level programming before, so I'd appreciate
> any suggestions or improvements I can make to it.
> 
> The patch is against natsemi.c version 1.0.17.
> 
> Thanks,
> Mark.
> 
