From: Rik van Riel <riel@redhat.com>
Subject: 2.6 ipv6 doesn't take route advertisements
Date: Mon, 10 Nov 2003 16:31:29 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311101629100.2898-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

it looks like the 2.6 kernel doesn't take default route
advertisements from either zebra or radvd.  I can see
the default routes being advertised with radvdump, but
they don't show up in the routing table of either of my
2.6 machines.  They both run a fairly recent 2.6 kernel.

Known bug ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
