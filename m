From: Takashi Hibi <hibi665@oki.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Fri, 13 Feb 2004 13:50:20 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213135020.fd1564f%hibi665@oki.com>
References: <OF3A5A0537.DEF35E29-ON88256E28.0073EBFF@us.ibm.com>
Mime-Version: 1.0
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>, davem@redhat.com, netdev@oss.sgi.com
In-Reply-To: (Your message of "Tue, 27 Jan 2004 14:13:41 -0700")
  <OF3A5A0537.DEF35E29-ON88256E28.0073EBFF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jan 2004 14:13:41 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> 
> Below is a patch that allows forcing of the IGMP version. The primary
> use would be with an IGMP-snooping switch that doesn't grok IGMPv3
> packet formats and when there are no IGMPv2 or IGMPv1 multicast
> routers on the network. By forcing the IGMP reports to version 2 (or
> version 1, for really old switches), Linux would send reports that the
> switch can understand for multicast forwarding to the port.
> 
>                         +-DLS

Do you have a plan to make a patch to force the MLD version?
I think it is also helpful.

Regards,
Takashi Hibi
