From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking update: summary (0/5)
Date: Sat, 08 Feb 2003 00:24:08 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030208.002408.52174985.davem@redhat.com>
References: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   linux-security-module@wirex.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Makan.Pourzandi@ericsson.ca
In-Reply-To: <7B2A7784F4B7F0409947481F3F3FEF8305CC9531@eammlex037.lmc.ericsson.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Makan Pourzandi (LMC)" <Makan.Pourzandi@ericsson.ca>
   Date: Fri, 7 Feb 2003 11:58:49 -0500 

   Actually, we know that based on FIPS documents
   (http://csrc.nist.gov/publications/fips/fips188/fips188.ps) we can
   use ip options for security purposes. I believe for my part that
   this hook can be useful if used to decode ip options and decide to
   drop or not the ip packets. I don't believe that this level of
   control can be achieved using other hooks at socket layer. 

James added a hook for SKB reception, you can do whatever you
want in analzying incoming packet contents using that generic
hook.
