From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [PATCH 2/6] IB: match connection requests based
	on	private data
Date: Mon, 06 Mar 2006 14:05:32 -0800
Message-ID: <440CB22C.6090007@ichips.intel.com>
References: <ORSMSX401FRaqbC8wSA00000005@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Roland Dreier' <rdreier@cisco.com>,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Sean Hefty <sean.hefty@intel.com>
In-Reply-To: <ORSMSX401FRaqbC8wSA00000005@orsmsx401.amr.corp.intel.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Sean Hefty wrote:
> +static void cm_mask_compare_data(u8 *dst, u8 *src, u8 *mask)
> +{
> +	int i;
> +
> +	for (i = 0; i < IB_CM_PRIVATE_DATA_COMPARE_SIZE; i++)
> +		dst[i] = src[i] & mask[i];
> +}
> +
> +static int cm_compare_data(struct ib_cm_private_data_compare *src_data,
> +			   struct ib_cm_private_data_compare *dst_data)
> +{
> +	u8 src[IB_CM_PRIVATE_DATA_COMPARE_SIZE];
> +	u8 dst[IB_CM_PRIVATE_DATA_COMPARE_SIZE];

Ugh.  I sent the wrong patch series.  This was the original set of patches, 
before any feedback was incorporated.  I will need to resend patches 2, 4, 5, 
and 6.  Sorry about this.

- Sean
