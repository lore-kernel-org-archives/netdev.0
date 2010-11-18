From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] phylib: Add support for Marvell 88E1149R devices.
Date: Thu, 18 Nov 2010 12:57:17 -0800 (PST)
Message-ID: <20101118.125717.52197531.davem@davemloft.net>
References: <1290038071-13296-3-git-send-email-ddaney@caviumnetworks.com>
	<20101118.114616.258106719.davem@davemloft.net>
	<20101118204410.GB16908@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org
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

From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Date: Thu, 18 Nov 2010 13:44:10 -0700

> On Thu, Nov 18, 2010 at 11:46:16AM -0800, David Miller wrote:
>> From: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>> Date: Wed, 17 Nov 2010 15:54:31 -0800
>> 
>> > The 88E1149R is 10/100/1000 quad-gigabit Ethernet PHY.  The
>> > .config_aneg function can be shared with 88E1118, but it needs its own
>> > .config_init.
>> > 
>> > Signed-off-by: David Daney <ddaney-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
>> 
>> Please resend this when you've respun patch #1 based upon the feedback
>> you've been given.
> 
> It looks to me that this patch has no dependencies on the first patch.
> ddaney; what say you?

It absolutely does, it references a function create by patch #1

In fact it's the whole _entire_ point of patch #1, to allow
patch #2 to be possible.  Did you even check?

Otherwise I would waste his time asking for a respin.
