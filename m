From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Fwd: [Bug 3397] New: Network connections hang going through an
 OpenBSD firewall]
Date: Tue, 14 Sep 2004 14:45:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914144549.1e3a3162@dell_ss3.pdx.osdl.net>
References: <41475BEA.2030803@us.ibm.com>
	<41475E1E.7010200@veus.hr>
	<414760E5.4010703@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vladimir <vlists@veus.hr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <414760E5.4010703@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 14:21:41 -0700
Nivedita Singhvi <niv@us.ibm.com> wrote:

> Vladimir wrote:
> 
> > It doesn't work with it. Should I download 2.6.8-1 from kernel.org and 
> > compile it by hand ?
> 
> If you can, download the latest (linux-2.6.9-rc2). You can
> get the patch against linux-2.6.8.1 vanilla from
> kernel.org.
> 
> > It is certainly possible but everything works fine with all other OSes 
> > and kernels 2.6.5 and below which leads me to believe something was 
> > changed in 2.6.6 that broke it.
> > 
> > Are you able to reproduce it ?
> 
> Unfortunately, I have zero cycles right now (and in the near
> future) to address any issues, I'm afraid. Someone on netdev
> will likely be able to help you or have run into it already.
> See Stephen's post from a few minutes ago..

Since the latest kernel chooses window scaling factor automatically, the 
value chosen by default is small enough that OpenBSD
busted pf will just make performance suck. If you want test it, you have to
increase tcp_rmem[2] or tcp_rmem_max to force a window scale > 2.
