From: cranium2003 <cranium2003@yahoo.com>
Subject: how netfilter handles fragmented packets
Date: Sun, 21 Nov 2004 07:31:54 -0800 (PST)
Message-ID: <20041121153154.85910.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
  netdev@oss.sgi.com
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: kernelnewbies@nl.linux.org
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

hello,
          In ip_output.c file ip_fragmet function when
create a new fragmented packet given to output(skb)
function. i want to know which function are actually
called by output(skb)?
          Is that function ip_finish_output? if yes
then fragmented packet has not gone through netfilter
hooks specially NF_IP_LOCAL_OUT?
          so does that mean fragmented packets not
travel through netfilter hooks?
regards,
cranium


		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - Get yours free! 
http://my.yahoo.com 
 


--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
