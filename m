From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Wed, 19 May 2004 13:27:00 +0300
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040519102700.GA16465@ee.oulu.fi>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com> <Pine.LNX.4.58.0405151354220.9894@fcat> <Pine.LNX.4.58.0405190256010.30653@fcat>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-admin@prism54.org>
To: Marc Herbert <marc.herbert@free.fr>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405190256010.30653@fcat>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

On Wed, May 19, 2004 at 11:30:28AM +0200, Marc Herbert wrote:
> - Me argues that we all lived happy for ages with this default
>   setting of 100 packets @ 100 Mb/s (and lived approximately happy @
>   10 Mb/s), but we'll soon see doom and gloom with this new and
>   brutal change to 1000 packets for all this _legacy_ 10-100 Mb/s
>   hardware. e1000 data only is not enough to justify this radical
>   shift.
> 
> If you are convinced by _both_ items above, then the patch below
> content _both_, and we're done.
> 
> If you are not, then... wait for further discussion, including answers
> to latest Ricardo's post.
Not to mention that not all modern hardware is gigabit, current
2.6 seems to be setting txqueuelen of 1000 for 802.11 devices too (at least
my prism54), which might be causing major problems for me.

Well, I'm still trying to figure out whether it's txqueue or WEP that causes
all traffic to stop (with rx invalid crypt packets showing up in iwconfig
afterwards, AP is a linksys wrt54g in case it makes a difference) every now
and then until a ifdown / ifup. Tried both vanilla 2.6 prism54 and CVS
(which seems to have a reset on tx timeout thing added), but if txqueue is
1000 that won't easily get triggered will it?
 
It's been running for a few days just fine with txqueue = 100 and no WEP, if
it stays like that i'll start tweaking to find what exactly triggers it.
