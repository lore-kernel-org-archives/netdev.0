From: Diego Beltrami <diego.beltrami@HIIT.FI>
Subject: Re: [Hipsec] [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Mon, 25 Jul 2005 16:28:55 +0300
Message-ID: <1122298135.14873.70.camel@odysse>
References: <1122295307.14873.37.camel@odysse>
Reply-To: diego.beltrami@HIIT.FI
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1122295307.14873.37.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,
I'm sorry but the sent patch included in the email seems to be broken.
Please, use the URL 
http://hipl.hiit.fi/beet/beet-patch-v1.0-2.6.12.2

Sincerely


> Hi folks,
> 
> we have been working for three months to implement a new IPsec mode,
> the "BEET" mode, for Linux. Below is a link to the BEET specification
> and
> the abstract:
> 
> http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt
> 
> Abstract
> 
>    This document specifies a new mode, called Bound End-to-End Tunnel
>    (BEET) mode, for IPsec ESP.  The new mode augments the existing ESP
>    tunnel and transport modes.  For end-to-end tunnels, the new mode
>    provides limited tunnel mode semantics without the regular tunnel
>    mode overhead.  The mode is intended to support new uses of ESP,
>    including mobility and multi-address multi-homing.
> 
> The BEET mode is required by the Host Identity Protocol (HIP), which
> provides authenticated Diffie-Hellman for end-hosts, as well as
> mobility and multihoming support. The BEET mode is also useful for
> other similar protocols being developed at the IETF.
> 
> Ericsson has already developed a BEET patch for *BSD. Our patch
> provides the similar functionality, but using the XFRM architecture.
> The patch is included at the end of this email and also at the following
> URL:
> http://hipl.hiit.fi/beet/beet-patch-v1.0-2.6.12.2
> 
> We have made some testing in order to assure the quality of the
> patch. All the tests passed, and below is a list of them:
> 
> * Does not break transport and tunnel mode (with CONFIG_XFRM_BEET
> on/off)
> * All inner-outer combinations with varying test applications:
>   ICMP, ICMPv6, FTP, SSH, nc, nc6
> * Works with fragmented packets
> * Interoperability with HIPL
> * Real machines, virtual machines (vmware)
> * Tested with long data streams
> 
> The BEET development team:
> 
> * Abhinav Pathak <abpathak@iitk.ac.in> (InfraHIP/HIIT)
> * Diego Beltrami <diego.beltrami@hiit.fi> (InfraHIP/HIIT)
> * Kristian Slavov <kristian.slavov@nomadiclab.com> (Ericsson)
> * Miika Komu <miika@iki.fi> (InfraHIP/HIIT)
> * Jeff Ahrenholz <jeffrey.m.ahrenholz@boeing.com> (Boeing)
> 
> On the behalf of the BEET development team,
> 
> Signed-off-by: Diego Beltrami <diego.beltrami@hiit.fi>
> 
> 
> 
