From: "Zhenyu Wu" <y030729@njupt.edu.cn>
Subject: Scheduler Mechnisms!
Date: Tue, 04 Jan 2005 11:15:37 +0800
Message-ID: <304808537.11599@njupt.edu.cn>
Reply-To: "Zhenyu Wu" <y030729@njupt.edu.cn>
Content-Type: text/plain
Cc: lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: netdev@oss.sgi.com
Sender: lartc-admin@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Hello,

Normally, in addition to such qdisc scheduler mechanisms as FIFO, PQ, WRR, WFQ,
are there any more? Then, there is a confusion on scheduler in Linux enviroment:
Assume there is a qdisc, such as RED as a leaf qdisc in a router, we know, if
there is packet which want to enqueue the packet, the Function red_enqueue is
called, but when the packet leave the queue(when the Function red_dequeue is
called)? I think it is meaningless when the pack leaves the queue just it enterred
it. Is there anything need to be done betweent the packet's enqueue and dequeue?

Best,


_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
