From: "David S. Miller" <davem@redhat.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 13:38:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.133841.35533284.davem@redhat.com>
References: <3EEE28DE.6040808@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, stekloff@us.ibm.com,
   girouard@us.ibm.com, lkessler@us.ibm.com, kenistonj@us.ibm.com,
   jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janiceg@us.ibm.com
In-Reply-To: <3EEE28DE.6040808@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Janice M Girouard <janiceg@us.ibm.com>
   Date: Mon, 16 Jun 2003 15:30:22 -0500

   EMSG_NET_LINK_UP     "%s: state change: link up, %d Mbps, %s-duplex\n"

Should indicate flow control state too.

   EMSG_NET_START_QUEUE "%s: performance event: (re)starting netdev queue\n"
   EMSG_NET_STOP_QUEUE  "%s: performance event: stopping netdev queue\n"

Oh _ABSOLUTELY NOT_, you're not printing a message
for normal events like this.  Especially those that are
going to occur on highly loaded systems.
