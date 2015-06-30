From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 21:01:17 +0200
Message-ID: <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
	<9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maninder Singh <maninder1.s@samsung.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 30, 2015 at 4:53 PM, Fujinaka, Todd <todd.fujinaka@intel.com> wrote:
> I don't see the reason this is needed so I'm going to say NAK.

Using generic functions is always better than open coded stuff.
Linux's ARRAY_SIZE also makes sure that the passed variable is actually
an array.

-- 
Thanks,
//richard
