From: Al Boldi <a1426z@gawab.com>
Subject: [RFC] ip / ifconfig redesign
Date: Fri, 2 Dec 2005 22:53:19 +0300
Message-ID: <200512022253.19029.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751009AbVLBT5f@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current ip / ifconfig configuration is arcane and inflexible.  The reason 
being, that they are based on design principles inherited from the last 
century.

In a GNU/OpenSource environment, OpenMinds should not inhibit themselves 
achieving new design-goals to enable a flexible non-redundant configuration.

Specifically, '#> ip addr ' exhibits this issue clearly, by requiring to 
associate the address to a link instead of the other way around.

Consider this new approach for better address management:
1. Allow the definition of an address pool
2. Relate links to addresses
3. Implement to make things backward-compatible.

The obvious benefit here, would be the transparent ability for apps to bind 
to addresses, regardless of the link existence.

Another benefit includes the ability to scale the link level transparently, 
regardless of the application bind state.

And there may be many other benefits... (i.e. 100% OSI compliance)

--
Al
