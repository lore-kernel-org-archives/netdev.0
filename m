From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 2.6.14-051107
Date: Tue, 8 Nov 2005 10:28:23 -0800
Message-ID: <20051108102823.0ab4cf62@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Update to iproute2 is available.  Most of the changes were to repair the
things that broke with the introduction of the batch mode to the ip command.
	http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.14-051107.tar.gz

For info on CVS ans other info see:
	http://linux-net.osdl.org/index.php/Iproute2

Masahide NAKAMURA
        * Updating for 2.6.14
        - Show UPD{SA,POLICY} message information from kernel instead of error
        - Add lengh check of deleting message from kernel
        - Use macro for struct xfrm_user{sa,policy}_id
        * Minor fix:
        - Add fflush at the end of normal dump
Jamal Hadi Salim 
        * Fix handling of XFRM monitor and state
 	* Fix ip rule flush, need to reopen rtnl
Stephen Hemminger 
        * Update to 2.6.14 sanitized headers
        * Add more CBQ examples from Fedora Core
        * Fix buffer overrun in iproute because of bits vs. bytes confusion
Patrick McHardy
        * Fix ip command shortcuts
