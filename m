From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] abstract out socket lock.users access
Date: Mon, 07 Oct 2002 15:53:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007.155332.32735975.davem@redhat.com>
References: <20021007175551.B30693@redhat.com>
	<20021007.151459.09774569.davem@redhat.com>
	<20021007185051.A25468@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com
In-Reply-To: <20021007185051.A25468@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Benjamin LaHaise <bcrl@redhat.com>
   Date: Mon, 7 Oct 2002 18:50:51 -0400
   
   Anyways, this version should be cleaned up, unless my eyes have glossed over 
   and missed something in reading through the patch.

Looks good, the sock_owned_by_user() is a needed good cleanup in
any event.

After some sleep I'll think some more about the async machinery
and probably just apply this unless someone else finds something
terribly wrong.
