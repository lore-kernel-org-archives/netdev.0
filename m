From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 19 May 2003 23:46:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519.234624.123976229.davem@redhat.com>
References: <20030519212209.P39592@shell.cyberus.ca>
	<20030519.182410.10302536.davem@redhat.com>
	<20030519220409.V39658@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@shell.cyberus.ca
In-Reply-To: <20030519220409.V39658@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jamal Hadi <hadi@shell.cyberus.ca>
   Date: Mon, 19 May 2003 22:13:33 -0400 (EDT)
   
   I dont think the hashes are similar - its the effect into the
   slow path. I was told by someone who tested this on a priicey CISCO
   that they simply die unless capable of a feature called CEF.

I found a description of this thing on Cisco's web site.  Amusingly it
seems to contradict itself, it says that the CEF FIB is fully
populated and has a 1-to-1 correspondance to the routing table yet it
says that the first access to some destination is what creates
CEF entries.

Go figure! :-)
