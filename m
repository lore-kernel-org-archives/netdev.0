From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] post-sysfs netdev cleanup
Date: Wed, 28 May 2003 01:33:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030528.013359.132929461.davem@redhat.com>
References: <3ECEB317.5020407@osdl.org>
	<20030525.192417.102551586.davem@redhat.com>
	<20030527095129.4bddbc51.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: muizelaar@rogers.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030527095129.4bddbc51.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 27 May 2003 09:51:29 -0700
   
   There needs to be some locking in the registration path doesn't there
   to prevent two calls to register the same name and other possible conflicts.
   So do you want to use dev_base lock or some other locking?
   
Good point.  We can't be as "fast and loose" with this as we
can with the hotplug invocation...

I can't come up with a usable solution at this moment. :(
