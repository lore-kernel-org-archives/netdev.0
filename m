From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [lanai] ioctl only meant for debugging (from
 mitch@sfgoth.com)
Date: Tue, 23 Sep 2003 03:57:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923035729.2aa1afd6.davem@redhat.com>
References: <20030922180749.A26432@infradead.org>
	<200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
In-Reply-To: <200309221755.h8MHt5kT010184@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2003 13:55:07 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> i suppose i am not convinced that two #ifdef/#endif's are better than an
> #if/#else/#endif

True, but how about we use an LANAI_DEBUG or something instead of "#if
0" that can sit undef'd at the top of the file?
