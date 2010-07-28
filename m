From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: RE: [REGRESSION] e1000e stopped working [MANUALLY BISECTED]
Date: Wed, 28 Jul 2010 10:04:43 +0300
Message-ID: <1280300683.8250.2.camel@maxim-laptop>
References: <1277659633.2989.2.camel@localhost.localdomain>
	 <1277659785.4028.1.camel@localhost.localdomain>
	 <1277660638.3321.1.camel@localhost.localdomain>
	 <1277660831.3321.3.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918F40A@orsmsx509.amr.corp.intel.com>
	 <1277745247.12841.1.camel@localhost.localdomain>
	 <8DD2590731AB5D4C9DBF71A877482A90015918FAB6@orsmsx509.amr.corp.intel.com>
	 <1277807529.19417.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4705C9D@rrsmsx501.amr.corp.intel.com>
	 <1277938757.4138.3.camel@localhost.localdomain>
	 <1278204106.21020.0.camel@localhost.localdomain>
	 <1278283714.3444.1.camel@localhost.localdomain>
	 <AANLkTin4sdPeExcNJkq4pfwIq0lcJuXtzTAACRW3JTFh@mail.gmail.com>
	 <1278323885.5277.0.camel@localhost.localdomain>
	 <1278950178.17933.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4A9B949@rrsmsx501.amr.corp.intel.com>
	 <1278981483.23017.4.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4B05AF9@rrsmsx501.amr.corp.intel.com>
	 <1279150380.7810.2.camel@localhost.localdomain>
	 <1279220266.4411.2.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FF4B860D9@rrsmsx501.amr.corp.intel.com>
	 <1279220945.4411.6.camel@localhost.localdomain>
	 <1279308358.3979.0.camel@localhost.localdomain>
	 <EA929A9653AAE14F841771FB1DE5A1365FFE1B19CD@rrsmsx501.amr.corp.intel.com>
	 <1279374897.8428.5.camel@localhost.localdomain>
	 <1280103959.2589.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61199 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749Ab0G1HEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 03:04:50 -0400
Received: by bwz1 with SMTP id 1so3747606bwz.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 00:04:49 -0700 (PDT)
In-Reply-To: <1280103959.2589.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-26 at 03:25 +0300, Maxim Levitsky wrote: 
> On Sat, 2010-07-17 at 16:54 +0300, Maxim Levitsky wrote:
> > On Fri, 2010-07-16 at 17:23 -0600, Tantilov, Emil S wrote:
> > > Maxim Levitsky wrote:
> > > > On Thu, 2010-07-15 at 22:09 +0300, Maxim Levitsky wrote:
> > > >> On Thu, 2010-07-15 at 13:02 -0600, Tantilov, Emil S wrote:
> > > >>> Maxim Levitsky wrote:
> > > >>>> On Thu, 2010-07-15 at 02:33 +0300, Maxim Levitsky wrote:
> > > >>>>> On Wed, 2010-07-14 at 16:56 -0600, Tantilov, Emil S wrote:
> > > >>>>>> Maxim Levitsky wrote:
> > > >>>>>>> On Mon, 2010-07-12 at 15:23 -0600, Tantilov, Emil S wrote:
> > > >>>>>>>> Maxim Levitsky wrote:
> > > >>>>>>>>> On Mon, 2010-07-05 at 12:58 +0300, Maxim Levitsky wrote:
> > > >>>>>>>>>> On Mon, 2010-07-05 at 01:13 -0700, Jeff Kirsher wrote:
> > > >>>>>>>>>>> On Sun, Jul 4, 2010 at 15:48, Maxim Levitsky
> > > >>>>>>>>>>> <maximlevitsky@gmail.com> wrote:
> > > >>>>>>>>>>>> Did few guesses, and now I see that reverting the below
> > > >>>>>>>>>>>> commit fixes the problem. 
> > > >>>>>>>>>>>> 
> > > >>>>>>>>>>>> "e1000e: Fix/cleanup PHY reset code for ICHx/PCHx"
> > > >>>>>>>>>>>> e98cac447cc1cc418dff1d610a5c79c4f2bdec7f.
> > > >>>>>>>>>>>> 
> > > >>>>>>>>>>>> 
> > > >>>>>>>>>>>> Best regards,
> > > >>>>>>>>>>>>        Maxim Levitsky
> > > >>>>>>>>>>>> 
> > > >>>>>>>>>>>> --
> > > >>>>>>>>>>> 
> > > >>>>>>>>>>> Can you give us till Tuesday to respond?  I know that there
> > > >>>>>>>>>>> are some additional e1000e patches in my queue, which may
> > > >>>>>>>>>>> resolve the issue, but this weekend the power is down to do
> > > >>>>>>>>>>> some infrastructure upgrades which prevents us from doing
> > > >>>>>>>>>>> any investigation.debugging until Tuesday.
> > > >>>>>>>>>>> 
> > > >>>>>>>>>> 
> > > >>>>>>>>>> Sure.
> > > >>>>>>>>>> 
> > > >>>>>>>>>> Best regards,
> > > >>>>>>>>>> 	Maxim Levitsky
> > > >>>>>>>>>> 
> > > >>>>>>>>> 
> > > >>>>>>>>> Updates?
> > > >>>>>>>> 
> > > >>>>>>>> We are working on reproducing the issue. So far we have not
> > > >>>>>>>> seen the problem when testing with net-next.
> > > >>>>>>>> 
> > > >>>>>>>> I asked in previous email about some additional info from
> > > >>>>>>>> ethtool (-d, -e, -S) and kernel config. That would help us to
> > > >>>>>>>> narrow it down. 
> > > >>>>>>>> 
> > > >>>>>>>> Thanks,
> > > >>>>>>>> Emil
> > > >>>>>>> I did send -e and -d output.
> > > >>>>>> 
> > > >>>>>> Sorry, looks like I lost the email with the attachements.
> > > >>>>>> 
> > > >>>>>> Could you provide the output of dmesg after the failure occurs?
> > > >>>>>> 
> > > >>>>>>> Since you probably want -S output during failure, I need to
> > > >>>>>>> recompile kernel for that. I will do that soon.
> > > >>>>>>> 
> > > >>>>>>> 
> > > >>>>>>> One question, in two weeks I hope 2.6.35 won't be released?
> > > >>>>>>> If so, I will have enough free time then to narrow down this
> > > >>>>>>> issue. 
> > > >>>>>>> 
> > > >>>>>>> Other solution, is to revert this commit.
> > > >>>>>>> (I have never seen this problem with it reverted).
> > > >>>>>> 
> > > >>>>>> We have been running reboot tests on 2 separate systems with
> > > >>>>>> recent net-next kernels using your config and so far no luck in
> > > >>>>>> reproducing this issue. 
> > > >>>>>> 
> > > >>>>>> What is the make model of your system (or MB)?
> > > >>>>> 
> > > >>>>> the motherboard is Intel DG965RY.
> > > >>>>> 
> > > >>>>> However, I am using vanilla kernel.
> > > >>>>> net-next might contain further fixes.
> > > >>>>> 
> > > >>>>> I see if net-next works here.
> > > >>>> 
> > > >>>> Yep, net-next works here.
> > > >>>> 
> > > >>>> 
> > > >>>> I have the problem on vanilla kernel.
> > > >>>> Last revision of it, I tested is 2.6.35-rc4 exactly
> > > >>>> (815c4163b6c8ebf8152f42b0a5fd015cfdcedc78)
> > > >>>> 
> > > >>>> 
> > > >>>> Maybe vanilla git master works, I test it too soon.
> > > >>> 
> > > >>> Thanks for the information! Good to know that this issue does not
> > > >>> exist in the latest branch. 
> > > >>> 
> > > >>> Have you by any chance tested a stable branch (2.6.34.x)?
> > > >> 
> > > >> I only did test plain 2.6.34 (v2.6.34)
> > > > And forgot to add, that it did work.
> > > > 
> > > >> 
> > > >> Also I repeat that revert of e98cac447cc1cc418dff1d610a5c79c4f2bdec7f
> > > >> (e1000e: Fix/cleanup PHY reset code for ICHx/PCHx) fixes the bug on
> > > >> vanilla kernel. 
> > > >> 
> > > >> Also I just pulled latest vanilla git, and I according to diffstat I
> > > >> see no changes in e1000e, so its likely that bug remains there.
> > > >> I will test that soon.
> > > > Tested, broken as expected.
> > > 
> > > That makes sense. Unfortunately we are still not able to reproduce even on recent pull from Linus tree.
> > > 
> > > If you want - you can look at the patches for e1000e in net-next and start applying those to your tree until the issue is resolved.
> > > 
> > That exactly what I will do soon.
> > 
> > 
> > Also I can narrow down the problem by reverting the commit partially.
> > 
> > After one week, I will have enough free time to do all the thing like
> > above. Now I have none.
> > 
> > 
> > > I will keep trying it here, but none of the systems we have exhibit the issue you described, so the bug could be exposed by something in your system/config.
> > I also think so. Otherwise, we would see more bug-reports.
> > 
> > You probably don't need to try anymore and reproduce that issue, because
> > of that.
> > 
> 
> 
> This commit, present in net-next, solves the problem:
> 
> commit 1286950690f0f82ffa504e1e149ee3fdb4c51478
> Author: Bruce Allan <bruce.w.allan@intel.com>
> Date:   Mon Jul 26 03:19:38 2010 +0300
> 
>     e1000e: cleanup e1000_sw_lcd_config_ich8lan()
>     
>     Do not acquire and release the PHY unnecessarily for parts that return
>     from this workaround without actually accessing the PHY registers.
>     
>     Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>     Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> 
> 
> Also, the above patch is part of whole series of patches with scary descriptions (that is these fix bugs).
> If I were you I would send them to Linus for 2.6.35 inclusion too.
> 
> Best regards,
> 	Maxim Levitsky
> 
> 
> 
ping


