From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLD compatibility mode doesn't account for extension headers [PATCH]
Date: Fri, 21 Nov 2003 18:29:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBEB2F853.C3E9EDB5-ON88256DE6.000D5DE0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org






>Looks good.  I assume that all extension headers must appear
>_before_ the igmp stuff, and therefore no other headers may
>appear afterwards.

Yes, MLD is the payload, so all extension headers must be
between the IPv6 header and the MLD header.

                        thanks, Dave,

                              +-DLS
