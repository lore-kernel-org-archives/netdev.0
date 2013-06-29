From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sat, 29 Jun 2013 00:04:57 -0700
Message-ID: <1372489497.3301.293.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	  <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
	  <1372402340.3301.229.camel@edumazet-glaptop>
	 <1372412262.3301.251.camel@edumazet-glaptop> <51CE1E19.3020108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CE1E19.3020108@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-06-29 at 07:36 +0800, Joe Jin wrote:
> Hi Eric,
> 
> The patch not fix the issue and panic as same as early I posted:


At least it fixes my own panics ;)

My test bed was :

Launch 24 concurrent "netperf -t UDP_STREAM -H destination -- -m 128"

Then on "destination" disconnect the ethernet port.

While the link flaps, I got panic in a few seconds.

Thanks
