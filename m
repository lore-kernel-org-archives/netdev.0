From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v6] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 5 Nov 2015 21:32:57 +0200
Message-ID: <CAHp75Ve2sLrNZGjD=1LHbyzQEuB2GMhXJxmBgQo1Y4eCHzPk+A@mail.gmail.com>
References: <20151105.103126.148818796422971143.davem@davemloft.net>
	<20151105.110506.1901401372160830603.davem@davemloft.net>
	<CAHp75VfiV6DVb-2piCxmEWFP4Gi-+n0qNhhscvd=UsqXrivVYg@mail.gmail.com>
	<20151105.133131.1900833527415923596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151105.133131.1900833527415923596.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 5, 2015 at 8:31 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Shevchenko <andy.shevchenko@gmail.com>
> Date: Thu, 5 Nov 2015 20:13:21 +0200
>
>> What about
>>
>> if (!addr)
>>  return -ENODATA;
>
> I totally disagree.  of_get_phy_mode() and other similar attribute
> probing mechanisms use -ENODEV.

Okay, then just
if (!addr)
 return -ENODEV;

-- 
With Best Regards,
Andy Shevchenko
