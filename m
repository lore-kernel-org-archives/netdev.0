From: "Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>
Subject: RE: [PATCH] iwl3945: queue the right work if the scan needs to be
 aborted
Date: Mon, 27 Sep 2010 12:59:18 -0700
Message-ID: <E9954878DD1FB34FAE5187FB88C58A35012BADC9EC@orsmsx506.amr.corp.intel.com>
References: <1285345323-4250-1-git-send-email-florian@mickler.org>
	<1285357868.12594.8.camel@wwguy-ubuntu>
 <20100927081358.07b30327@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Chatre, Reinette" <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Zhu Yi <yi.zhu@intel.com>,
	"Cahill, Ben M" <ben.m.cahill@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Mickler <florian@mickler.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100927081358.07b30327@schatten.dmk.lab>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Agree the patch is needed for .35 and .36.

Thanks

Wey

-----Original Message-----
From: Florian Mickler [mailto:florian@mickler.org]
Sent: Sunday, September 26, 2010 11:14 PM
To: Guy, Wey-Yi W
Cc: linux-wireless@vger.kernel.org; Chatre, Reinette; Intel Linux Wireless; John W. Linville; Berg, Johannes; Zhu Yi; Cahill, Ben M; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] iwl3945: queue the right work if the scan needs to be aborted

On Fri, 24 Sep 2010 12:51:08 -0700
"Guy, Wey-Yi" <wey-yi.w.guy@intel.com> wrote:

> Hi Florian,
>
> Thanks for sending the patch, the scan operation in iwlwifi just being
> modified and the changes you have no longer apply.please check the
> latest kernel.
>
> Thanks
> Wey
>

Ok, I checked out
git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-2.6.git
and it definitely looks better in there. This patch shouldn't be
necessary for that.

Do you plan on submitting this for 2.6.36 or .37?

I think my patch should fix the instance reported in the bug in a less
invasive manner.
Only remaining question is why it did only show up now. But that's
probably due to the workqueue changes.


Regards,
Flo
