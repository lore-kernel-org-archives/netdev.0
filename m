From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Linux-2.6.3 : [eth0: Too much work at interrupt,
 status=0x00000001.]
Date: Fri, 20 Feb 2004 11:34:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220113427.0a088fb9@dell_ss3.pdx.osdl.net>
References: <200402201803.12146.andrew@walrond.org>
	<20040221.032006.68375681.yoshfuji@linux-ipv6.org>
	<200402201915.09342.andrew@walrond.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Walrond <andrew@walrond.org>
In-Reply-To: <200402201915.09342.andrew@walrond.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 19:15:09 +0000
Andrew Walrond <andrew@walrond.org> wrote:

> On Friday 20 Feb 2004 6:20 pm, YOSHIFUJI Hideaki / ____________ wrote:
> > In article <200402201803.12146.andrew@walrond.org> (at Fri, 20 Feb 2004 
> 18:03:11 +0000), Andrew Walrond <andrew@walrond.org> says:
> >
> > I've got this several times, randomly, and
> > I had to go to the console to reboot the machine.
> >
> 
> Well the machine and network (at least with just ssh access) is working fine
> 
> I left the machine (which is a remote rack-mounted server) for an hour and now 
> there is perhaps 120 of these warnings. Net is still working though.
> 
> Unless anyone has any ideas, I'll move back to 2.4 on this machine
> 
> Andrew

The driver needs to be converted to NAPI to sustain high network loads.
The existing driver allocates and copies each receive packet in the interrupt routine.

See the recent revision of 8139too to see what that entails.
