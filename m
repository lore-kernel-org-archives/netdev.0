From: "David S. Miller" <davem@redhat.com>
Subject: Re: sysctl variable to force IGMP version [PATCH]
Date: Wed, 28 Jan 2004 12:00:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128120003.0d5f3df2.davem@redhat.com>
References: <OF3A5A0537.DEF35E29-ON88256E28.0073EBFF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF3A5A0537.DEF35E29-ON88256E28.0073EBFF@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jan 2004 14:13:41 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> Below is a patch that allows forcing of the IGMP version. The primary
> use would be with an IGMP-snooping switch that doesn't grok IGMPv3
> packet formats and when there are no IGMPv2 or IGMPv1 multicast
> routers on the network. By forcing the IGMP reports to version 2 (or
> version 1, for really old switches), Linux would send reports that the
> switch can understand for multicast forwarding to the port.

Perhaps some sanity to prevent values other than 1 or 2 from being
set?
