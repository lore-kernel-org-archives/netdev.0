From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Patch submission for S2io Xframe driver to 2.6 kernel
Date: Thu, 16 Sep 2004 20:58:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916205849.55ce05e5.rddunlap@osdl.org>
References: <413116FF.7000701@pobox.com>
	<002201c499b4$7c7b60c0$a010100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        raghavendra.koushik@s2io.com, rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: <ravinandan.arakali@s2io.com>
In-Reply-To: <002201c499b4$7c7b60c0$a010100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 10:09:53 -0700 Ravinandan Arakali wrote:

| Hi Jeff,
| Attached is the patch with the first round comments incorporated.
| In addition, this patch contains
| Some fixes related to 32-bit systems.
| Few fixes related to Rx path in NAPI.
| 
| Thanks to all for the comments.
| 
| Pls review this patch as well and come back with your comments.


1.  typo?  first name is still used in source code:

-static char s2io_driver_version[] = "Version 1.0";
+static char s2iO_driver_version[] = "Version 1.1";

2.  don't init. globals to 0 -- it's done automatically for you.


(more this weekend....)

--
~Randy
