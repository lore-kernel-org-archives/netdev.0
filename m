From: Andi Kleen <ak@suse.de>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Sat, 24 Jan 2004 15:58:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124155809.15fe167e.ak@suse.de>
References: <1074914062.1036.39.camel@jzny.localdomain>
	<000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Leonid Grossman" <leonid.grossman@s2io.com>
In-Reply-To: <000001c3e238$62efbb30$0400a8c0@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jan 2004 21:10:28 -0800
"Leonid Grossman" <leonid.grossman@s2io.com> wrote:


> In Linux, there are couple performance issues that we see
> - transmit performance is noticeably worse than in Windows

In Linux 2.6 with TSO?

Other than that I would suggest to enable oprofile on 2.6 and post 
the profile numbers on the list.

> - checksum in 2.4 seems to be calculated by the host even if the device
> enables checksum offload

You have to use sendfile() for TX checksum off load. Without that the 
data needs to be copied anyways and a copy+csum is about the same cost
as a simple copy.

> - Large Send Offload in 2.6 (no LSO in 2.4) give much smaller boost
> comparing to Windows; on some systems there is no gain from LSO at all.

You mean TSO? Are you sure the test programs submitted big enough 
buffers to the TCP stack?
 

-Andi
