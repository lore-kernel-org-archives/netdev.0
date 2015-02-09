From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net:ethernet:intel:Remove outdated fix me comment in the function,gb_acquire_swfw_sync_i210
Date: Mon, 09 Feb 2015 10:29:35 +0100
Message-ID: <87egpzqvpc.fsf@nemi.mork.no>
References: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
	<1423444889.2589.165.camel@jtkirshe-mobl> <54D85EFA.3020501@gmail.com>
	<1423470722.27854.11.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrej Manduch <amanduch@gmail.com>,
	Nicholas Krause <xerofoify@gmail.com>,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423470722.27854.11.camel@jtkirshe-mobl> (Jeff Kirsher's message
	of "Mon, 09 Feb 2015 00:32:02 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:

> If you want to see Nick's patch, feel free to view his patch on
> my queue tree:
> https://git.kernel.org/cgit/linux/kernel/git/jkirsher/queue.git/

which said:
  - s32 i =3D 0, timeout =3D 200; /* FIXME: find real value to use here=
 */
  + s32 i =3D 0, timeout =3D 200;


Comments like the one deleted by that patch do have some value in my
opinion: They document that the constant is chosen arbitrarily and is
not taken from some datasheet.

Not a big deal, but leaving such comments, even if the value never ever
changes, could save someone from trying to figure out where the heck yo=
u
got that constant.  And there's noone actually misinterpreting this
comment as "something needs to be fixed here", is there? So the cost of
leaving the comment is exactly zero.

Just my .02 =E2=82=AC.  I'm not going to tell you how to maintain your =
driver,
of course.  At least I try not to :-)


Bj=C3=B8rn
