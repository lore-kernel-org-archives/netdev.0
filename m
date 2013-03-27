From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
Subject: Re: ieee802154: Source addr fix for dgram and
 some small at86rf230 driver enhancements
Date: Wed, 27 Mar 2013 21:21:25 +0000
Message-ID: <20130327212125.GA23555@novatech.datenfreihafen.org>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
	<20130327.005318.1058473513349640907.davem@davemloft.net>
	<20130327185204.GH22584@novatech.datenfreihafen.org>
	<20130327.151037.378525240140621201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130327.151037.378525240140621201.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On Wed, 2013-03-27 at 15:10, David Miller wrote:
> From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
> Date: Wed, 27 Mar 2013 18:52:05 +0000
> 
> > On Wed, 2013-03-27 at 00:53, David Miller wrote:
> >> From: Stefan Schmidt <stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org>
> >> Date: Tue, 26 Mar 2013 22:41:28 +0000
> >> 
> >> > Hello.
> >> > 
> >> > Second version. Changes since version 1:
> >> > - Obey 80 chars rules
> >> > - Switch logging mode to vdbg to avoid noise
> >> > - Remove uneeded might_sleep()
> >> > 
> >> > Thanks Alan, Werner and Alex for the feedback.
> >> > 
> >> > I feel these are ready so I added DaveM and netdev to pick them up if they think
> >> > the same.
> >> 
> >> All applied.
> > 
> > Thanks. That was quick. :)
> > 
> > I wonder what happened to the from of two of my commits. Looking at
> > your repo they only show up my email address:
> > 
> > https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1486774d69f6e58da16cdae8f17c77ec6569f711
> > https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=028889b0b32064a3a23d6d8d4ef589a42a6d43c7
> > 
> > The one from Stephen is fine
> > https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=6364e6ee788ae60f1c2de5c59e39adb157327e6c
> > 
> > The later as an explicit from as he was the author and I just the
> > sender. For the two problematic ones git am should have picked up the
> > normal mail from header, no?
> 
> I don't understand what the problem is.
> 
> The first two patches list you as the author, as that is the sender in
> the From: field.

Yeah, sorry. Should have made that more clear.

> Oh, I see, the name, have a look at:
> 
> http://patchwork.ozlabs.org/patch/231579/
> 
> That's where I take the patches from, click on Download "mbox" and you'll
> see that it gave me the headers as:
> 
> Date: Tue, 26 Mar 2013 12:41:30 -0000
> From: stefan-OrPQZGeq07wqhVmZOOOmNx2eb7JE58TQ@public.gmane.org

Strange, patchwork somehow got the From wrong. Looking through the
headers again it seems all correct to me. The only occurance of my
email without proper name is the return-path which should should not
matter.

Its not a big deal anyway, just strange.

regards
Stefan Schmidt

------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
