From: greg chesson <greg@atheros.com>
Subject: Re: generic 802.11 stack
Date: Wed, 15 Sep 2004 07:47:36 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <41485608.3040509@atheros.com>
References: <4145352F.4040807@pobox.com> <20040915030545.GA25307@havoc.gtf.org> <20040915031732.GL7839@ruslug.rutgers.edu> <200409150844.45242.vkondra@mail.ru>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
 acx100-devel@lists.sourceforge.net,
 "David S. Miller" <davem@davemloft.net>,
  hadi@cyberus.ca, Jeff Garzik <jgarzik@pobox.com>,
 "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
  netdev@oss.sgi.com,  prism54-devel@prism54.org,  sam@errno.com
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200409150844.45242.vkondra@mail.ru>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org



Vladimir Kondratiev wrote:
> Let me answer to the set of questions raised:
> 
> - dual licensing: I am not ready to answer for legal. I will discuss with 
> proper people and answer.
end the end it is your choice.
> 
> - code style: regardless of answer on question above, I intend to do Linux 
> work and will not care about compatibility macros. I really dislike such 
> macros, they do make code hard to understand.
This is true - and it's not just compatibility macro's that force
the reader to find and read the macro before understanding the code.
But there is a fine line between macro's that are accepted as standard
practice in a kernel, e.g. LIST_INSERT_HEAD, and the same kind
of thing that is used in a driver for compatibility across different
versions of the Linux kernel or, dog save us, some other unix-like OS.
> 
> - information sharing (driver-stack): good question indeed. I am currently 
> evaluating it. This far, I think I will supply some standard link layer 
> information per packet. Like rate, RSSI etc. For Tx, it will include also 
> crypto key for hardware assisted encryption, type of protection (RTS/CTS 
> etc.) I believe it should be sufficient. To prove it, I am going to write 
> some dummy .11 driver that will be capable to simulate any Rx, with user 
> interface for feeding packets. I will use this driver to debug stack.
2 cents of advice: the rx path is the easier side.
the more complex and fun stuff happens on the tx side.
> 
> It is complex issue to support all combination of job separation between host 
> and NIC, I will choose some model like "NIC do almost nothing" and will 
> develop around it. 
very reasonable.
> 
> Vladimir.
> 
> On Wednesday 15 September 2004 06:17, Luis R. Rodriguez wrote:
> LR> On Tue, Sep 14, 2004 at 11:05:45PM -0400, Jeff Garzik wrote:
> LR> > On Tue, Sep 14, 2004 at 11:02:11PM -0400, Luis R. Rodriguez wrote:
> LR> > > I proposed dual licensing not to specifically allow clear
>  compatibility LR> > > among linux and the BSDs on the 802.11 work, but to
>  allow BSDers to do LR> > > whatever they want with what we come up with --
>  help with code sharing. LR> >
> LR> >
> LR> > Overall, He Who Writes The Code Gets To Choose.
> LR> >
> LR> > My own personal opinion is that the BSD license goes against the stated
> LR> > spirit of Linux -- contribute back.  But that's just me.
> LR> >
> LR>
> LR> Agreed -- but in this case I feel we're the bigger crowd so I wanted to
> LR> address to the *author* that I feel we should be considerate to the BSD
> LR> crowd.
> LR>
> LR>  Luis
> LR
> 



-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
