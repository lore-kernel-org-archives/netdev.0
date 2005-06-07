From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2-ss050607
Date: Tue, 7 Jun 2005 15:43:24 -0700
Message-ID: <20050607154324.0b280333@unknown-215.office.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl,
	netdev@oss.sgi.com
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small update to iproute2, I have been waiting to get a CVS conversion
completed and working on other things so changes are small.
http://developer.osdl.org/dev/iproute2/download/iproute2-ss050607.tar.gz

Stephen Hemminger 
	* Fix 'ip link' map to handle case where device gets autoloaded
	  by using if_nametoindex as fallback
	* Device indices are unsigned not int.

Masahide NAKAMURA 
	
	* [ip] show timestamp when using '-t' option.
	* [ip] remove duplicated code for expired message of xfrm.
	* [ip] add "deleteall" command for xfrm;
	  "flush" uses kernel's flush interface and
	  "deleteall" uses legacy iproute2's flush feature like
	   getting-and-deleting-for-each.

This is the first export from the CVS repo, so let me know if there
are any quirks.
If you have something you want to see in the next release and it isn't
there please resend.
