From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Small Help required!!!
Date: Mon, 1 Nov 2004 13:49:17 -0800
Message-ID: <OF4B619707.EA6E09C8-ON88256F3F.007783E0-88256F3F.0077DEBE@us.ibm.com>
References: <BLEAIJDEHOOAGALIAAKBMEPCCCAA.pranav@nodeinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <BLEAIJDEHOOAGALIAAKBMEPCCCAA.pranav@nodeinfotech.com>
To: <pranav@nodeinfotech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev-bounce@oss.sgi.com wrote on 10/30/2004 08:32:55 AM:

> hi,
> I needed some information about how to proceed with implementing a Name
> Switch Server plugin that
> allows to resolve multicast DNS names using normal libc calls(such as
> gethostbyname()).

> If someone has knowledge in this regard,please mail me back.

I think this will already work as-is. All you should need to do is
register the multicast address in the DNS server.

Have you tried it? Some well-known multicast addresses (like NTP's) are
commonly registered with root servers already.

I haven't tried using "gethostbyame()" on a multicast address that is
registered, but I'm not aware of any checks on the class of the address
in any of the code.

                                        +-DLS
