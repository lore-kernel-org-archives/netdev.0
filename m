From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [DESC 2.6.8.1-mm4] r8169 patches
Date: Fri, 27 Aug 2004 10:09:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408271009.41099.jdmason@us.ltcfwd.linux.ibm.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040823224100.GA14680@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been running the driver with all of the new patchs on my AMD64 system for 
over 36 hours without any problems.  I have Rx/TX checksumming enabled, but 
have not tried the VLAN changes.

On Monday 23 August 2004 05:41 pm, Francois Romieu wrote:
> Here comes a new serie of r8169 related patches which should allow
> the motivated users to experiment new features, namely:
> - Rx/Tx checksum offload;
> - vlan support;
> - better ethtool integration.
>
> Tx code apart, the changes exhibit some strong similarity with the
> 8139cp driver.
>
> I have not done vlan-dedicated test and there are no figures to highlight
> any performance improvement. The code does not crash in a (really slow)
> debug enabled -mm kernel and it does not seem to add huge leak.
>
> Remarks/comments/test reports welcome.
>
> --
> Ueimor

-- 
Jon Mason
jdmason@us.ibm.com
