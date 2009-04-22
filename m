From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v2 fixed] e100: do not go D3 in shutdown
	unless system is powering off
Date: Wed, 22 Apr 2009 22:55:54 +0200
Message-ID: <200904222255.55508.rjw@sisk.pl>
References: <1240237621-11415-1-git-send-email-cascardo@holoscopio.com>
	<20090422193728.GI4691@vespa.holoscopio.com>
	<9929d2390904221322v1c00b0c8see98efb4354cb173@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2390904221322v1c00b0c8see98efb4354cb173@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday 22 April 2009, Jeff Kirsher wrote:
> On Wed, Apr 22, 2009 at 12:37 PM, Thadeu Lima de Souza Cascardo
> <cascardo@holoscopio.com> wrote:
> > On Tue, Apr 21, 2009 at 10:46:19PM -0700, Jeff Kirsher wrote:
> >> On Tue, Apr 21, 2009 at 9:38 PM, Thadeu Lima de Souza Cascardo
> >> <cascardo@holoscopio.com> wrote:
> >> > After experimenting with kexec with the last merges after 2.6.29, I've
> >> > had some problems when probing e100. It would not read the eeprom. After
> >> > some bisects, I realized this has been like that since forever (at least
> >> > 2.6.18). The problem is that shutdown is doing the same thing that
> >> > suspend does and puts the device in D3 state. I couldn't find a way to
> >> > get the device back to a sane state in the probe function. So, based on
> >> > some similar patches from Rafael J. Wysocki for e1000, e1000e and ixgbe,
> >> > I wrote this one for e100.
> >> >
> >> > Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> >> > ---
> >>
> >> Thanks, I will add it to my queue of patches for e100.
> >>
> >> Also, just FYI, Auke is no longer a maintainer for
> >> e100/e1000/e1000e/igb/ixgb/ixgbe devices, so I have removed him from
> >> the thread.
> >>
> >> --
> >> Cheers,
> >> Jeff
> >
> > Perhaps, Rafael should be mentioned in a Reviewed-by? As well as you if
> > you did review it? I guess a Tested-by and Reported-by me is overkill,
> > right? :-)
> >
> 
> Correct, that would be overkill.  If Rafael wants his Ack or
> Reviewed-by added, he will let us know.

Please add my ACK to the patch.

Best,
Rafael

------------------------------------------------------------------------------
Stay on top of everything new and different, both inside and 
around Java (TM) technology - register by April 22, and save
$200 on the JavaOne (SM) conference, June 2-5, 2009, San Francisco.
300 plus technical and hands-on sessions. Register today. 
Use priority code J9JMT32. http://p.sf.net/sfu/p
