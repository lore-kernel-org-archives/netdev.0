From: "David S. Miller" <davem@redhat.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 08:55:04 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.085504.105424448.davem@redhat.com>
References: <3E5E7081.6020704@nortelnetworks.com>
	<1046695876.7731.78.camel@pc-16.office.scali.no>
	<3E638C51.2000904@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: terje.eggestad@scali.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3E638C51.2000904@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Friesen <cfriesen@nortelnetworks.com>
   Date: Mon, 03 Mar 2003 12:09:37 -0500

   Unless you poll for messages on the receiving side, how do you trigger 
   the receiver to look for a message?

Send signals.  Use a FUTEX, be creative...
