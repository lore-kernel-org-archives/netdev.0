From: Janice Girouard <girouard@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 21:12:50 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFCA1A4F38.D782F1D3-ON85256D48.000A5CED@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel Stekloff <stekloff@us.ibm.com>, janiceg@us.ibm.com,
   jgarzik@pobox.com, Larry Kessler <lkessler@us.ibm.com>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





  From: Janice Girouard <girouard@us.ibm.com>
   Date: Mon, 16 Jun 2003 19:44:22 -0500

   It sounds like you are proposing a new family for the netlink
   subsystem.

   From: "David S. Miller" <davem@redhat.com>

   Date:06/16/2003 08:19 PM


   Exactly, you have to create this.



Okay.  That solves the issue of events generated in a plethora of formats
for the same event.  Any suggestions on what should be included in this new
family?  I can present a patch to suggest a starting point. However, it
would be great to hear from everyone that has any initial thoughts.



One question that comes to mind, since there is some overlap with netdev
notifier events, should we include those events in the new family?  I can
envision a couple of approaches:



1) keep the two interfaces (netdev notifier and netlink), with separate end
users in mind and duplicate the events to each interface.  Possibly
thinking about migrating to just one interface over time.  Applications
would then just receive one set of events.



2) keep the two interfaces, with no duplication of messages, clarifying the
uses for the two interfaces.  An application would then register, and
obtain events from the two separate mechanisms.

p.s. thanks for all the input so far.
