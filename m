From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 0/4 linux-2.6.9-rc3/linux-2.4.28-pre3]
	prism54 bugs/patches
Date: Sat, 2 Oct 2004 16:34:56 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410021634.56857.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

2004-10-02 Margit Schubert-While <margitsw@t-online.de>

* 01_remtrace.patch
*  Remove TRACE to please the janitors

* 02_schedbug.patch
*  Bug in loop around schedule_timeout
*  We must rearm the task
*
*  Make timeout message meaningful

* 03_fwprint.patch
*  Print firmware version
*
*  As per convention, make errno return negative

* 04_mgtcommit.patch
*  Change mgt_commit from void to int
*  We call this from device initialization,
*  therefore we need to know that it has succeeded
*  If it hasn't, we do not have a working device and
*  should pass a non-zero value upwards

Jeff, as usual, applies to both 2.4 and 2.6;
however, there are outstanding patches for 2.4.

Margit
