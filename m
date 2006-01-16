From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [patch] networking ipv4: remove total socket usage count from
	/proc/net/sockstat
Date: Mon, 16 Jan 2006 15:14:05 -0500
Message-ID: <1137442446.19444.20.camel@mindpipe>
References: <20060116200432.GB14060@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751186AbWAPUOL@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20060116200432.GB14060@gospo.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-01-16 at 15:04 -0500, Andy Gospodarek wrote:
> Printing the total number of sockets used in /proc/net/sockstat is out
> of place in a file that is supposed to contain information related to
> ipv4 sockets.  Removed output for total socket usage.
> 

Um, you can't do that, it will break userspace.

Lee
