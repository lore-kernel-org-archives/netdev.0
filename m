From: "David S. Miller" <davem@redhat.com>
Subject: Re: Linux and Wake-On-Lan
Date: Wed, 07 May 2003 01:06:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507.010630.48509535.davem@redhat.com>
References: <20030507090530.91065.qmail@web9703.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lucas75it@yahoo.it
In-Reply-To: <20030507090530.91065.qmail@web9703.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Gianluca Masone <lucas75it@yahoo.it>
   Date: Wed, 7 May 2003 11:05:30 +0200 (CEST)

   Suppose i put a net device in wake-on-lan status.
   There is some kernel function that notifies presence
   of a wake packet ?

This is not how wake-on-lan works.

When your computer is put to sleep (via APM or ACPI),
the network card can listen for the wake packets.

If it is listening and a wakeup packet is received, your computer
wakes up from sleep state.

All of this happens in the hardware, all Linux can do is
enable/disable the feature.
