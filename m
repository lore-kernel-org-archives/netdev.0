From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Fri, 18 Feb 2005 23:11:21 +0100
Message-ID: <20050218221121.GA22845@electric-eye.fr.zoreil.com>
References: <20050218134219.3f079110.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.olsson@its.uu.se, netdev <netdev@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050218134219.3f079110.rddunlap@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap <rddunlap@osdl.org> :
> (resend)
> Any comments this time?

Did I miss a simultaneous use of both buffers or could it be possible to
save an extra IP_NAME_SZ bytes of data with an evil ugly union ?

Btw, does anyone intend to fix the use of sleepable functions in 
proc_thread_write() with spinlock ("thread_lock") held or should
I allocate it some cycles ?

--
Ueimor
