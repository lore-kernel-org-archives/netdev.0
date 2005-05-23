From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Mon, 23 May 2005 14:14:00 -0500
Message-ID: <200505231414.00146.jdmason@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro> <200505201354.46824.jdmason@us.ibm.com> <Pine.LNX.4.62.0505231226160.20838@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505231226160.20838@webhosting.rdsbv.ro>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The code applies the ~ first, then the | and _then_ the &.
> If we have:
> a &= a | ~b;
> it is equivalent with:
> a = a & (a | ~b);

 Ah, that is what I was missing.  Sorry.
