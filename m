From: Lars Landmark <larslan@merete.zapto.org>
Subject: Class crash (linux)
Date: Fri, 21 Mar 2003 08:57:54 +0100 (CET)
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <Pine.LNX.4.44.0303201542170.20947-100000@merete.balder.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <linux-net@vger.kernel.org>
Return-path: <lartc-admin@mailman.ds9a.nl>
To: lartc@mailman.ds9a.nl
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org

Hi;

I am working width a project intended for developing an adaptive class 
based QoS system for Linux.
I have been struggling width a bug for a long time now. The bug has been
tracked to procedure tc_ctl_class() in file linux/net/sched/sch_api.c.
In this function there are a switch test, in order to test whether
NEWCLASS or other flags are set.

If RTM_NEWCLASS flag is set, a if test is performed:
if (n->nlmsg_flags&NLM_F_EXCL)

What does this if test perform, especially what does NLM_F_EXCL flag 
represent.


When I attach a new class, this test result true. The next step after a
goto call, is to test if there are a class pointer. If there are a
class pointer, an oops call "oops->put(q, cl)" is done.. In this call my  
system crash.

Is there any approach in order to solve the oops. ??

Lars Landmark
Student

_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
