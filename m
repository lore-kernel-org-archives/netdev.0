From: Dan Williams <dcbw@redhat.com>
Subject: Adding an IW_QUAL_ALL_UPDATED macro
Date: Thu, 27 Jan 2005 21:27:55 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0501272121120.2149@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean,

Can we add something like:

#define IW_QUAL_ALL_UPDATED (IW_QUAL_QUAL_UPDATED
                             | IW_QUAL_LEVEL_UPDATED
                             | IW_QUAL_NOISE_UPDATED)

#define IW_QUAL_ALL_INVALID (IW_QUAL_QUAL_INVALID
                             | IW_QUAL_LEVEL_INVALID
                             | IW_QUAL_NOISE_INVALID)

these macros to wireless.h?  This would be helpful for drivers, many 
of which seem to have "qual.updated = 7; /* all updated */" type 
statements in them.

I'm also attempting to normalize some of the quality values in the 
drivers, and to develop an understanding of the spreads of the quality 
values in all of them.  I hope to post the data from this evaluation at 
some point.  I'm fixing up the in-kernel drivers (and ipw2200 driver) to 
correctly set the "qual.updated" field since most of them don't.

Dan
