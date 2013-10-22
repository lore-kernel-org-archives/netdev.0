From: Dave Taht <dave.taht@bufferbloat.net>
Subject: [PATCH 0/2] net-next codel enhancements
Date: Mon, 21 Oct 2013 18:19:55 -0700
Message-ID: <1382404797-17239-1-git-send-email-dave.taht@bufferbloat.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	codel@lists.bufferbloat.net
Return-path: <codel-bounces@lists.bufferbloat.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

These two patches have been extensively tested in openwrt
and cerowrt. Losing the fq_codel drop statistic as a bug.

Checking for a maxpacket size in the qdisc was somewhat 
correct for ns2 but not for Linux as all the current 
subsystems below htb/hfsc/adsl/bql buffer packets.

IMHO both of these patches are candidates for stable. 
