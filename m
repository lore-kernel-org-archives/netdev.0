From: "David S. Miller" <davem@redhat.com>
Subject: Re: gettime: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 20:30:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.203015.104061804.davem@redhat.com>
References: <20030610.203325.41658167.davem@redhat.com>
	<20030611065255.L39678@shell.cyberus.ca>
	<20030611120803.GB22720@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030611120803.GB22720@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 11 Jun 2003 14:08:03 +0200

   Another way is to just store jiffies (= 10 or 1ms accuracy) 
   
   This should be nearly zero cost and accurate enough at least for TCP.
   
TCP doesn't use it Andi.  SO_RECVSTAMP etc. uses it and that
MUST be accurate.

People, start approaching this from an actually implementable
angle, not one's that have no basis in reality :)

   
