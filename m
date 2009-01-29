From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 20/21] RDS: Kconfig and Makefile
Date: Wed, 28 Jan 2009 21:14:27 -0800
Message-ID: <adaocxqsngs.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-21-git-send-email-andy.grover@oracle.com>
	<adazlhbt4ta.fsf@cisco.com> <4981123E.2060406@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4981123E.2060406@oracle.com> (Andy Grover's message of "Wed, 28
	Jan 2009 18:19:42 -0800")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > So the solution is just to base debug message output on a variable,
 > instead of a config option? RDS actually does do this a little already,
 > so converting totally isn't hard. I hadn't seen mention this was
 > preferable -- indeed, tons of drivers and subsystems have options for
 > compile-time debug statements, should these be converted?

My experience is definitely that compile-time switches are a big pain
when you actually have to debug something that can only be reproduced on
someone else's setup (which will happen once users start using your
stuff).  You probably can use the dynamic_printk stuff that went in
recently to make this all very clean and standard.

 - R.
