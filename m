From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] Network packet type using RCU
Date: Mon, 19 May 2003 00:22:19 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519.002219.02298937.davem@redhat.com>
References: <20030509142538.548cbd71.shemminger@osdl.org>
	<20030514072006.D23367@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030514072006.D23367@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Wed, 14 May 2003 07:23:32 -0400 (EDT)

   Apologies i was offline for a bit so dont know the history here.
   I see a lot of move to rcu. There are benefits to using RCU in certain
   cases (example occasional list edit with a lot more reads). Why does
   there  seem to be a massive migration it seems to RCU? Something wrong
   with the linked lists?
   
If you only need one of two synchronization primitives, why
have two? :-)
