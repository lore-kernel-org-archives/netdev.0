From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown
	command
Date: Sat, 31 Oct 2009 10:58:38 -0700
Message-ID: <20091031105838.0d4b59a2@nehalam>
References: <4AEC05E8.40600@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, Andrew Morton <akpm@linux-foundation.org>,
	svaidy@linux.vnet.ibm.com, davem@davemloft.net
To: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4AEC05E8.40600@miraclelinux.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, 31 Oct 2009 18:39:52 +0900
Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:

> Hi All
> 
> I resend my patch.
> Sorry, my previous mail lacked an explanation.
> 
> 
> The e1000 driver doesn't let the power down when running ifdown command.
> So, I set to the D3hot state of a PCI device at the end of e1000_close().
> 
> With this modification, e1000 driver reduces power by ifdown.
> It's about 6 watts when I measured a total power of one server machine
> in my environment.
> 
> I tested this patch. The result is good enough to me.
> 
> Could you please check my patch ?
> If I should have other considerations, please tell me.
> 


Does this work with Wake On Lan? 

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
