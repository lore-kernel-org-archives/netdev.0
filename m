From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: Wed, 21 May 2003 16:22:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.162216.21916460.davem@redhat.com>
References: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com, dm@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: daniel@osdl.org
In-Reply-To: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Daniel McNeil <daniel@osdl.org>
   Date: 21 May 2003 13:48:32 -0700

   Here is simple patch to remove MOD_INC_USE_COUNT and
   MOD_DEC_USE_COUNT.  The wanrouter module will get a reference
   when another module uses its exported symbols.
   
What if that other module doesn't get loaded?
The things registered in procfs need to have their
->owner field set.
