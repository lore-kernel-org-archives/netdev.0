From: cranium 2003 <cranium.2003@gmail.com>
Subject: ethernet cache question
Date: Mon, 31 Jan 2005 16:26:06 +0530
Message-ID: <1d55641b050131025636a00d1e@mail.gmail.com>
Reply-To: cranium 2003 <cranium.2003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: kernelnewbies@nl.linux.org, netdev@oss.sgi.com
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

Hello,
      By looking at structure hh_cache it is seen that hh_output is structure
variable defined as
unsigned long   hh_data[HH_DATA_ALIGN(LL_MAX_HEADER) / sizeof(long)];
Then i want to know how its sufficient in linux kernel to copy cache ethernet
header entry as
memcpy(skb->data - 16, hh->hh_data, 16);
other variable defined in hh_cache is not seen as copied to packet structure.
How then ethernet header is copied to packet if ethernet header has cache
entry stored in hh_cache structure defiend in /usr/src/include/netdevice.h
regards,
cranium

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
