From: James Morris <jmorris@intercode.com.au>
Subject: Re: 2.5.68 comments -  [udp broadcast reception broken]
Date: Tue, 22 Apr 2003 16:58:08 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0304221649550.4809-100000@excalibur.intercode.com.au>
References: <3EA382F1.205@tmsusa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>, <dlstevens@ibm.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: J Sloan <joe@tmsusa.com>
In-Reply-To: <3EA382F1.205@tmsusa.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Apr 2003, J Sloan wrote:

> Looks good for the most part, but the rwhod
> problem is still with us. (The system is unable
> to receive udp broadcasts since early in the
> 2.5.67-bk release series)

This is being caused by the call to ip_mc_sf_allow() during packet
delivery, which is not needed for broadcasts.

(Broadcast & multicast packets share the same delivery path here).


- James
-- 
James Morris
<jmorris@intercode.com.au>
