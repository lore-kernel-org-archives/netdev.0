From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: patch for common networking error messages
Date: Tue, 17 Jun 2003 09:08:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617090859.0ffa0ca8.shemminger@osdl.org>
References: <OFCA1A4F38.D782F1D3-ON85256D48.000A5CED@us.ibm.com>
	<200306170434.h5H4YZPZ003025@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: girouard@us.ibm.com, davem@redhat.com, stekloff@us.ibm.com,
   janiceg@us.ibm.com, jgarzik@pobox.com, lkessler@us.ibm.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200306170434.h5H4YZPZ003025@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Binary interface's will never cut it.  Read the hotplug thread to see how Linus
said, he will never add a binary event daemon interface.

That said, there is an oppurtunity for to provide a ascii interface (similar to
/sbin/hotplug) decodes the data from the rtnetlink interface in a standardized format.

Then it would be easy to write things like perl monitoring scripts that do things
like:
	perl phone-me-if-network-dies.pl < /proc/net/events

Don't flame me about the choce of name. /proc/net/events is not the right name 
to use for such an interface since adding more to /proc is probably not desired.
