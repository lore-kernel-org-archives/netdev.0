From: "David S. Miller" <davem@redhat.com>
Subject: Re: PATCH: IPSec not using padding when Null Encryption
Date: Mon, 03 Mar 2003 01:28:25 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.012825.81834528.davem@redhat.com>
References: <200302272129.h1RLTJW28434@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: latten@austin.ibm.com
In-Reply-To: <200302272129.h1RLTJW28434@faith.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: latten@austin.ibm.com
   Date: Thu, 27 Feb 2003 15:29:19 -0600
   
   Ok, anyway, this fix just pretty much makes sure that
   when Null Encryption or any algorithm with a blocksize less
   than 4 is used, that the ciphertext, any padding, and next-header
   and pad-length fields terminate on a 4-byte boundary.
   I have tested it. Please let me know if all is well. 

Applied, thanks.
