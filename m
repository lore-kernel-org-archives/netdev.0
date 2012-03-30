From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Fri, 30 Mar 2012 11:17:43 -0400
Message-ID: <CAAsGZS4mK-XNeyPiWsDX6ntfsoeqOEVNQ7ObAcp4c7jGG8O8VQ@mail.gmail.com>
References: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
	<CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
	<20120327180501.GA3878@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DC68D@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS7+L5Y7Mo8pipJf=T6x9vTUAcTS93t=BGsmCUvA3T31Zw@mail.gmail.com>
	<CAAsGZS6=wCPKC_1HnXQNn=U=6h-akbWvLZ_9ztBjfva=DFmugQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DC769@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS75TStwzTsRnpMGMqPy=h1AoV5uKyguXa92LvAsG4BXOQ@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DD9C8@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48393 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296Ab2C3PRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 11:17:43 -0400
Received: by mail-pb0-f46.google.com with SMTP id un15so1882261pbc.19
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:17:43 -0700 (PDT)
In-Reply-To: <02874ECE860811409154E81DA85FBB580DD9C8@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 29, 2012 at 7:08 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:

>
> I performed this test on my machine. Even with a buggy app that calls clock_gettime
> inside a while loop, this does not produce any contention whatsoever with
> time stamping. I checked the timestamps returned also, and it appears to be running
> more than 20k times a second.
>

Great. Thanks for running the tests. I'm all set.

Intel/Richard - thanks for being patient.

Chetan
