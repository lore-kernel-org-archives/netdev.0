From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 05 Sep 2002 23:51:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020905.235159.128049953.davem@redhat.com>
References: <20020905.204721.49430679.davem@redhat.com>
	<18563262.1031269721@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin.Bligh@us.ibm.com
In-Reply-To: <18563262.1031269721@[10.10.2.3]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
   Date: Thu, 05 Sep 2002 23:48:42 -0700
   
   Just to throw another firework into the fire whilst people are 
   awake, NAPI does not seem to scale to this sort of load, which
   was disappointing, as we were hoping it would solve some of 
   our interrupt load problems ...

Stupid question, are you sure you have CONFIG_E1000_NAPI enabled?

NAPI is also not the panacea to all problems in the world.

I bet your greatest gain would be obtained from going to Tux
and using appropriate IRQ affinity settings and making sure
Tux threads bind to same cpu as device where they accept
connections.

It is standard method to obtain peak specweb performance.
