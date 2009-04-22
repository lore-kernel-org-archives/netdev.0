From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 fixed] e100: do not go D3 in shutdown
	unless system is powering off
Date: Tue, 21 Apr 2009 22:46:19 -0700
Message-ID: <9929d2390904212246n4817b25r4db653cd7e6a24c1@mail.gmail.com>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com>
	<200904202114.01932.rjw@sisk.pl>
	<20090421215248.GF6147@vespa.holoscopio.com>
	<200904220017.19670.rjw@sisk.pl>
	<20090422043828.GB3979@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090422043828.GB3979@vespa.holoscopio.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 9:38 PM, Thadeu Lima de Souza Cascardo
<cascardo@holoscopio.com> wrote:
> After experimenting with kexec with the last merges after 2.6.29, I've
> had some problems when probing e100. It would not read the eeprom. After
> some bisects, I realized this has been like that since forever (at least
> 2.6.18). The problem is that shutdown is doing the same thing that
> suspend does and puts the device in D3 state. I couldn't find a way to
> get the device back to a sane state in the probe function. So, based on
> some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
> I wrote this one for e100.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> ---

Thanks, I will add it to my queue of patches for e100.

Also, just FYI, Auke is no longer a maintainer for
e100/e1000/e1000e/igb/ixgb/ixgbe devices, so I have removed him from
the thread.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
Stay on top of everything new and different, both inside and 
around Java (TM) technology - register by April 22, and save
$200 on the JavaOne (SM) conference, June 2-5, 2009, San Francisco.
300 plus technical and hands-on sessions. Register today. 
Use priority code J9JMT32. http://p.sf.net/sfu/p
