From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Problem with 2.4.24 e1000 and keepalived
Date: Thu, 8 Jan 2004 09:47:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108084758.GB9050@alpha.home.local>
References: <20040107200556.0d553c40.skraw@ithnet.com> <20040107210255.GA545@alpha.home.local> <3FFCC430.4060804@candelatech.com> <20040108091441.3ff81b53.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>
Content-Disposition: inline
In-Reply-To: <20040108091441.3ff81b53.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2004 at 09:14:41AM +0100, Stephan von Krawczynski wrote:
> the situation is like this (exactly this works flawlessly with tulip):
> 
> - unplug all interfaces from the switches
> - reboot box
> - plug in _one_ interface 
> - log into the box (yes, network works flawlessly)
> - start keepalived
> - now plug in rest of the interfaces
> - watch keepalived do _nothing_ (seems no UP event shows up)

I agree with this description, and would add :
  - mii-diag ethX or ethtool ethX report link down

Willy
