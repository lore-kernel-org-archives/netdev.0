From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Re: Problems with a PCI SMC2802W
Date: Wed, 16 Mar 2005 19:33:47 +0100
Message-ID: <20050316183347.GA25595@electric-eye.fr.zoreil.com>
References: <422F118D.8070704@voicenet.com>
	<20050309160744.GN4017@Redstar.dorchain.net>
	<20050309202718.4f94b871@veagle.suse.cz>
	<20050310021724.GD17854@ruslug.rutgers.edu>
	<42302133.2060103@voicenet.com>
	<20050310103608.GB1416@taniwha.stupidest.org>
	<20050310163007.GK17854@ruslug.rutgers.edu>
	<20050316162448.GR17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Wedgwood <cw@f00f.org>, Jeff Garzik <jgarzik@pobox.com>,
	Netdev <netdev@oss.sgi.com>, Adam K Kirchhoff <adamk@voicenet.com>,
	prism54-devel@prism54.org, Feyd <feyd@seznam.cz>
Content-Disposition: inline
In-Reply-To: <20050316162448.GR17854@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu> :
[...]
> If no comment is given on how we should deal with
> pci_dma_sync_single/pci_dma_sync_single_for_cpu for 2.4 I'm just going
> to put in a nasty ifdef there. Comemnts?

My out of tree 2.4.x driver for the 8169 exhibits a few differences
with the 2.6.x driver for these kind of things. Over several months,
it happened once that a 2.6.x patch hit this part of the code. Let's
say an extra 5 minutes to merge in 2.4.x and no side effects as I had
to actually look at the code (of course orthogonal patches helped).

Imho it is not a heavy maintenance/taste issue.

--
Ueimor
