From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: filtering packtes before OS takes care about them
Date: Tue, 1 Mar 2005 09:20:58 -0800
Message-ID: <20050301092058.570ed623@dxpl.pdx.osdl.net>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
To: "Weber Matthias" <weber@faps.uni-erlangen.de>
In-Reply-To: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Feb 2005 17:16:57 +0100
"Weber Matthias" <weber@faps.uni-erlangen.de> wrote:

> Hi,
> 
> i need a possibility to catch IP4 packets (from ethernet devices) before OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care about them and 
> * to delete them from input buffer such that OS' netmodules can't receive them
> * to modify packet headers and move packets to interface related output buffers
> * to keep them in input buffers such that OS' netmodules can take care about them.
> 
> I would be thankfull for any hint, link or code example.
> 
> Bye
> Matthias

If you need this as a "one off" type project, then another possibility is
to hook onto netif_rx with jprobe (part of the kprobe) to redirect traffic
to a local function first.  
It wouldn't useable for a real production type protocol.
