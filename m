From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 19:06:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020917.190641.84134530.davem@redhat.com>
References: <3D87A4A2.6050403@mandrakesoft.com>
	<20020917.144911.43656989.davem@redhat.com>
	<3D87E0C2.6040004@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@mandrakesoft.com
In-Reply-To: <3D87E0C2.6040004@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@mandrakesoft.com>
   Date: Tue, 17 Sep 2002 22:11:14 -0400
   
   You're looking at at least one extra get-irq-status too, at least in the 
   classical 10/100 drivers I'm used to seeing...
   
How so?  The number of ones done in the e1000 NAPI code are the same
(read register until no interesting status bits remain set, same as
pre-NAPI e1000 driver).

For tg3 it's a cheap memory read from the status block not a PIO.
