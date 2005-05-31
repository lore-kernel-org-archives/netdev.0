From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 802.1q/MTU bug
Date: Wed, 1 Jun 2005 00:31:02 +0200
Message-ID: <20050531223102.GA29707@electric-eye.fr.zoreil.com>
References: <20050530071148.GB1514@electric-eye.fr.zoreil.com> <200505301927.26110.james@grickle.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Harr <james@grickle.org>
Content-Disposition: inline
In-Reply-To: <200505301927.26110.james@grickle.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Harr <james@grickle.org> :
[...]
> The driver you sent gives me an error when I try to compile and load it with 
> 2.6.11.11:

The driver that I sent you builds with 2.6.12-rc4. Please try 2.6.12-rc4 +
the aforementioned driver.

If it still crashes (?), tell if your .config matches:

CONFIG_R8169=m
CONFIG_R8169_NAPI=y
# CONFIG_R8169_VLAN is not set

or:

CONFIG_R8169=m
CONFIG_R8169_NAPI=y
CONFIG_R8169_VLAN=y

An history of the commands issued to set the config before the crash
would be welcome too.

--
Ueimor
