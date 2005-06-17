From: =?ISO-8859-2?Q?Tom=E1=B9_Macek?= <maca02@atlas.cz>
Subject: Re: receive only one record from the routing table
Date: Fri, 17 Jun 2005 20:57:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
 <20050617141527.GN22463@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050617141527.GN22463@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Part of my routing table is here:

3.3.0.0         *               255.255.0.0     U     0      0        0 eth1
default         meric           0.0.0.0         UG    0      0        0 eth0

Ommiting NLM_F_DUMP and typing './a.out 3.3.0.0' gives

Error in recieved packet: Success
Read From Socket Failed...

and I don't see the reason why... I think, it should write something with the 3.3.0.0 destination, but writes the error above instead


On Fri, 17 Jun 2005, Thomas Graf wrote:

> * Tom?? Macek <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain> 2005-06-17 14:51
>>      nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
>>      nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .
>>
>>      nlMsg->nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;   // The message is a request for dump.
>
> Omit NLM_F_DUMP and you'll be fine, see rfc3549.
>
>
>
>
>
