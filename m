From: Raanan Avargil <raanan.avargil@intel.com>
Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly on
 some I218 controllers
Date: Tue, 9 Aug 2016 18:10:53 +0300
Message-ID: <f9d596bd-226b-0faf-bab1-858823f17ee4@intel.com>
References: <579F407E.9090602@compulab.co.il>
 <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
 <57A6F7A9.1030401@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denis Turischev <denis.turischev@compulab.co.il>,
	intel-wired-lan@lists.osuosl.org,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57A6F7A9.1030401@compulab.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 8/7/2016 11:56, Denis Turischev wrote:
> Hi Raanan,
>
> On 08/04/2016 07:18 PM, Raanan Avargil wrote:
>> It is hard to determine what is exactly the problem here and what causes the -3 error, but this is not the place to perform hw reset and retry to init the phy.
> I agree that may be this is not the correct place for hw reset, can you advice about another solution?
>
> It works, not only for me, for example it helps here:
> http://www.linux.org.ru/forum/linux-hardware/10268216
>
> Another fact that Windows drivers work fine with the same hw.
>
> Denis
>

Hi Denis,

More suitable place to retry init the device would be in probe function.
However, we haven't seen initialization issues like this on i218.

Adding Aaron.

@Aaron - have you seen initialization errors on i218 devices?

Raanan
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
