From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/2] phylib: Add support for Marvell 88E1149R devices.
Date: Thu, 18 Nov 2010 13:06:53 -0800
Message-ID: <4CE5956D.5020507@caviumnetworks.com>
References: <1290038071-13296-1-git-send-email-ddaney@caviumnetworks.com>
	<1290038071-13296-3-git-send-email-ddaney@caviumnetworks.com>
	<20101118.114616.258106719.davem@davemloft.net>
	<20101118204410.GB16908@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20101118204410.GB16908-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/18/2010 12:44 PM, Grant Likely wrote:
> On Thu, Nov 18, 2010 at 11:46:16AM -0800, David Miller wrote:
>> From: David Daney<ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>> Date: Wed, 17 Nov 2010 15:54:31 -0800
>>
>>> The 88E1149R is 10/100/1000 quad-gigabit Ethernet PHY.  The
>>> .config_aneg function can be shared with 88E1118, but it needs its own
>>> .config_init.
>>>
>>> Signed-off-by: David Daney<ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>>
>> Please resend this when you've respun patch #1 based upon the feedback
>> you've been given.
>
> It looks to me that this patch has no dependencies on the first patch.
> ddaney; what say you?
>

It calls the marvell_of_reg_init() function introduced in the first 
patch.  Reordering the patches would be possible, but since nobody else 
has cared enough to add 88E1149R support, it shouldn't affect anyone be 
me.

I arbitrarily ordered it this way.  If davem wishes, I could re-order 
the patches and 88E1149R could be merged before the device tree part.

David Daney
