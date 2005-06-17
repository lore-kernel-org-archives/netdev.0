From: Thomas Graf <tgraf@suug.ch>
Subject: Re: receive only one record from the routing table
Date: Fri, 17 Jun 2005 16:15:27 +0200
Message-ID: <20050617141527.GN22463@postel.suug.ch>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-8859-1?B?VG9t4T8=?= Macek <maca02@atlas.cz>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Tom?? Macek <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain> 2005-06-17 14:51
>      nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
>      nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .
> 
>      nlMsg->nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;   // The message is a request for dump.

Omit NLM_F_DUMP and you'll be fine, see rfc3549.
