From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: turning off tcp checksums.
Date: Fri, 28 Jan 2005 10:10:39 -0800
Message-ID: <20050128101039.654abf2a@dxpl.pdx.osdl.net>
References: <d50018af05012809595096dafe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sudeep list <sudeep.list@gmail.com>
In-Reply-To: <d50018af05012809595096dafe@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 10:59:31 -0700
sudeep list <sudeep.list@gmail.com> wrote:

> hello,
> 
> I am trying to conduct some throughput experiments using a modified
> TcP/IP stack. One of the things that I would like to do is to turn off
> the TcP checksum. The idea is that the application computes its own
> checksum, and having tcp duplicate the effort with a weaker checksum
> doesnt make sense. This still leaves the tcp header without any
> checksum, but since this is a lab environment, I hope to get away with
> it for now :-)

Not allowed per RFC's and "forget about it", since the copy path
does checksumming at almost no cost. If you still think it is a
real issue then get a NIC that supports hardware checksumming.

-- 
Stephen Hemminger	<shemminger@osdl.org>
