From: "David S. Miller" <davem@redhat.com>
Subject: Re: Ethernet bridge performance
Date: Thu, 7 Aug 2003 12:58:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807125828.625b6640.davem@redhat.com>
References: <3F3217E7.2080903@allot.com>
	<3F3284EA.5050406@candelatech.com>
	<20030807123547.1dcf2353.davem@redhat.com>
	<3F32AD9D.4010504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: felix@allot.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F32AD9D.4010504@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Aug 2003 12:50:53 -0700
Ben Greear <greearb@candelatech.com> wrote:

> David S. Miller wrote:
> > In 2.6.x, play with /proc/sys/vm/min_free_kbytes
> 
> Anything to set for 2.4?  I've looked for how to tune the 2.4 VM for
> some time, but never found anything.

Good question.  Nothing exists there.

The per-zone ->pages_min value is what is controlled by this
settting.  It should be easy to backport the 2.6.x sysctl to
2.4.x, even for an amateur :-)
