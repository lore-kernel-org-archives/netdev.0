From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: TCP/IP Window Size Problem/Query
Date: Tue, 12 Aug 2003 19:05:18 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308121905.18313.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A0251E6BE@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hare, Matthew" <matthew.hare@amsjv.com>, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A0251E6BE@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 11 August 2003 07:22 pm, Hare, Matthew wrote:
> I have two systems running SuSE Linux. System 1 is running SuSE 7.1
> with the 2.2.18 kernel. System 2 is running SuSE 7.3 with the
> 2.4.17 kernel. Both systems are PC based (Pentium III, 512MB RAM).
>
>
> When I open a TCP connection from System 1 I get a reported window
> size (I use Ethereal to check window sizes) of 32k. When I do the
> same with System 2 I get a reported window size of 5840bytes and
> the window size increases as the rate of data being sent via TCP
> increases. This is causing me problems, I need a fixed window size
> of 32k on System 2 so that it matches System 1.
>

We've encountered similar behavior on a server running Red Hat 9 
starting with the ~5k window size and publishing it is willing to 
increase it (forgot the exact name of the flags), problem is the 
clients are all w2k systems (for using Chariot as the performance 
analyzer), and they don't seem to be able to handle that kind of 
window size management, so we're always stuck with the original ~5k 
window size and the performance sucks. When using w2k on the same 
server, everything starts with 64k window, so the performance is 
great.

Isn't there a way to ask the TCP/IP stack not to begin with small 
window size and then try to increase, but rather start with the 
largest windows size and then decrease ?
Using jumbo frames and TSO doesn't seem to help a lot.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
