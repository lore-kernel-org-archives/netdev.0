From: Andrew Walrond <andrew@walrond.org>
Subject: Re: Linux-2.6.3 : [eth0: Too much work at interrupt, status=0x00000001.]
Date: Fri, 20 Feb 2004 20:01:58 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402202001.58343.andrew@walrond.org>
References: <200402201803.12146.andrew@walrond.org> <200402201915.09342.andrew@walrond.org> <20040220113427.0a088fb9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040220113427.0a088fb9@dell_ss3.pdx.osdl.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 20 Feb 2004 7:34 pm, Stephen Hemminger wrote:
>
> The driver needs to be converted to NAPI to sustain high network loads.
> The existing driver allocates and copies each receive packet in the
> interrupt routine.
>
> See the recent revision of 8139too to see what that entails.

Yes but...there were no high network loads. Just me typing into ssh.

STOP PRESS....FIX...

That may well be so, but I rebuilt the kernel with the optional MMIO on the 
rhine driver, and the messages have disappeared.

I have also used wget to fetch a 100Mb file at an average 1.02Mb/s and it 
worked flawlessly and still no warnings in dmesg.

Andrew Walrond
