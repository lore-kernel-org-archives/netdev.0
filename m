From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: iptables problem upgrading kernel from 3.18.8 to 3.19.1
Date: Mon, 16 Mar 2015 14:54:14 +0100
Message-ID: <20150316135414.GA25978@kroah.com>
References: <54FC2089.6080809@unsolicited.net>
 <20150308175553.GA1528@breakpoint.cc>
 <20150312.154756.1175332873553032640.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, david@unsolicited.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	stable@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150312.154756.1175332873553032640.davem@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 12, 2015 at 03:47:56PM -0400, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sun, 8 Mar 2015 18:55:53 +0100
> 
> > David R <david@unsolicited.net> wrote:
> > 
> > [ CC Pablo & stable@ ]
> > 
> >> I've just had an exception to my "uneventful kernel upgrade" monotony.
> >> 
> >> My boot scripts failed when setting up the firewall due to this :-
> >> 
> >>     xt_recent: hitcount (1) is larger than packets to be remembered (1)
> >> for table xxxx
> >> 
> >> This is a completely straightforward
> >> 
> >>     iptables -A yyyy -j REJECT -p tcp --reject-with tcp-reset -m recent
> >> --set --name xxxx --rsource
> >> 
> >> Looking at the history for xt_recent.c it looks like this was introduced
> >> in abc86d0f99242b7f142b7cb8f90e30081dd3c256 but maybe corrected in
> >> cef9ed86ed62eeffcd017882278bbece32001f86 ?
> > 
> > Right.  I would recommend to revert abc86d0f99242b7f142b7cb8f90e30081dd3c256
> > in 3.19.y series rather than applying cef9ed86ed62, though.
> 
> Greg, please queue up a revert of abc86d0f99242b7f142b7cb8f90e30081dd3c256 for
> 3.19.x -stable, if you haven't done so already.

Now done, thanks.

greg k-h
