From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 20:30:04 +0100
Message-ID: <200412172030.04831.oliver@neukum.org>
References: <41C26DD1.7070006@trash.net> <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com> <41C330F7.4000806@dbservice.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: linux-os@analogic.com, Bill Davidsen <davidsen@tmr.com>,
        James Morris <jmorris@redhat.com>, Patrick McHardy <kaber@trash.net>,
        Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Carnecky <tom@dbservice.com>
In-Reply-To: <41C330F7.4000806@dbservice.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> But the difference between you example (cp /dev/zero /dev/mem) and 
> passing unchecked data to the kernel is... you _can_ check the data and 

This is the difference:
static int open_port(struct inode * inode, struct file * filp)
{
	return capable(CAP_SYS_RAWIO) ? 0 : -EPERM;
}
(from mem.c)

	Regards
		Oliver
